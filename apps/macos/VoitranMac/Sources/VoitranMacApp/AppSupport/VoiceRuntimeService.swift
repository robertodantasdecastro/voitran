import Foundation
import RealtimeCore

enum VoiceRuntimeError: LocalizedError {
    case scriptNotFound(String)
    case invalidResponse
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .scriptNotFound(let path):
            "sidecar nao encontrado em \(path)"
        case .invalidResponse:
            "sidecar retornou um payload invalido"
        case .commandFailed(let message):
            message
        }
    }
}

struct VoiceRuntimeService {
    func health() async throws -> VoiceRuntimeHealth {
        try await run(command: "health", input: EmptyPayload())
    }

    func enroll(request: VoiceEnrollmentRequest) async throws -> VoiceEnrollmentResult {
        try await run(command: "enroll", input: request)
    }

    func synthesize(request: VoiceSynthesisRequest) async throws -> VoiceSynthesisResult {
        try await run(command: "synthesize", input: request)
    }

    func listProfiles() async throws -> [VoiceProfile] {
        let response: ListProfilesResponse = try await run(command: "list-profiles", input: EmptyPayload())
        return response.profiles
    }

    func inspectProfile(id: String) async throws -> VoiceProfileInspection {
        try await run(command: "inspect-profile", input: ProfileRequest(voiceProfileID: id))
    }

    func revokeProfile(id: String) async throws -> RevokeResponse {
        try await run(command: "revoke-profile", input: ProfileRequest(voiceProfileID: id))
    }

    func bootstrap() async throws -> BootstrapResponse {
        let script = RuntimePaths.bootstrapScript
        guard FileManager.default.isExecutableFile(atPath: script.path) else {
            throw VoiceRuntimeError.scriptNotFound(script.path)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [script.path]
        process.currentDirectoryURL = RuntimePaths.workingDirectory

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()

        let output = String(decoding: outputPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        let error = String(decoding: errorPipe.fileHandleForReading.readDataToEndOfFile(), as: UTF8.self)
        if process.terminationStatus != 0 {
            throw VoiceRuntimeError.commandFailed(error.isEmpty ? output : error)
        }

        return BootstrapResponse(output: output.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private func run<T: Decodable & Sendable, Input: Encodable>(command: String, input: Input) async throws -> T {
        let script = RuntimePaths.sidecarScript
        guard FileManager.default.isExecutableFile(atPath: script.path) else {
            throw VoiceRuntimeError.scriptNotFound(script.path)
        }

        let payload = try JSONEncoder().encode(input)

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [script.path, command]
            process.currentDirectoryURL = RuntimePaths.workingDirectory

            let inputPipe = Pipe()
            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardInput = inputPipe
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            process.terminationHandler = { process in
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorText = String(decoding: errorData, as: UTF8.self)

                guard process.terminationStatus == 0 else {
                    continuation.resume(throwing: VoiceRuntimeError.commandFailed(errorText.trimmingCharacters(in: .whitespacesAndNewlines)))
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(T.self, from: outputData)
                    continuation.resume(returning: decoded)
                } catch {
                    let rawOutput = String(decoding: outputData, as: UTF8.self)
                    continuation.resume(throwing: VoiceRuntimeError.commandFailed(rawOutput.isEmpty ? error.localizedDescription : rawOutput))
                }
            }

            do {
                try process.run()
                inputPipe.fileHandleForWriting.write(payload)
                try inputPipe.fileHandleForWriting.close()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}

private struct EmptyPayload: Encodable {}

private struct ListProfilesResponse: Decodable {
    let profiles: [VoiceProfile]
}

private struct ProfileRequest: Encodable {
    let voiceProfileID: String

    enum CodingKeys: String, CodingKey {
        case voiceProfileID = "voice_profile_id"
    }
}

struct BootstrapResponse: Equatable {
    let output: String
}

struct RevokeResponse: Decodable, Equatable {
    let revoked: Bool
    let voiceProfileID: String

    enum CodingKeys: String, CodingKey {
        case revoked
        case voiceProfileID = "voice_profile_id"
    }
}
