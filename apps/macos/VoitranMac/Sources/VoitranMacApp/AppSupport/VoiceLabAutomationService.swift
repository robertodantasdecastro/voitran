import Foundation

struct VoiceLabAutomationService {
    func latestSamples() async throws -> VoiceLabSampleSummary {
        try await run(arguments: ["latest-samples"])
    }

    func trainLatest(ownerLocalID: String, sourceLocale: String, targetLocale: String) async throws -> VoiceLabTrainingReport {
        try await run(arguments: [
            "train-latest",
            "--owner-local-id", ownerLocalID,
            "--source-locale", sourceLocale,
            "--target-locale", targetLocale
        ])
    }

    func smoke(ownerLocalID: String, sourceLocale: String, targetLocale: String, text: String) async throws -> VoiceLabSmokeReport {
        try await run(arguments: [
            "smoke",
            "--owner-local-id", ownerLocalID,
            "--source-locale", sourceLocale,
            "--target-locale", targetLocale,
            "--text", text
        ])
    }

    private func run<T: Decodable & Sendable>(arguments: [String]) async throws -> T {
        guard FileManager.default.isExecutableFile(atPath: RuntimePaths.voiceLabScript.path) else {
            throw VoiceRuntimeError.scriptNotFound(RuntimePaths.voiceLabScript.path)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [RuntimePaths.voiceLabScript.path] + arguments
            process.currentDirectoryURL = RuntimePaths.workingDirectory

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe

            process.terminationHandler = { process in
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                let errorText = String(decoding: errorData, as: UTF8.self).trimmingCharacters(in: .whitespacesAndNewlines)

                guard process.terminationStatus == 0 else {
                    continuation.resume(throwing: VoiceRuntimeError.commandFailed(errorText))
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
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
