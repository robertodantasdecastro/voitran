import Foundation

enum ManagedServicesError: LocalizedError {
    case scriptNotFound(String)
    case commandFailed(String)

    var errorDescription: String? {
        switch self {
        case .scriptNotFound(let path):
            "script de servicos nao encontrado em \(path)"
        case .commandFailed(let message):
            message
        }
    }
}

struct ServicesRuntimeService {
    private var scriptURL: URL {
        RuntimePaths.repoRoot.appendingPathComponent("scripts/voitran_services.sh")
    }

    func statusAll() async throws -> ManagedServicesResponse {
        try await run(arguments: ["status-all"])
    }

    func startAll() async throws -> ManagedServicesResponse {
        try await run(arguments: ["start-all"])
    }

    func stopAll() async throws -> ManagedServicesResponse {
        try await run(arguments: ["stop-all"])
    }

    func start(serviceID: String) async throws -> ManagedServicesResponse {
        _ = try await runRaw(arguments: ["start", serviceID])
        return try await statusAll()
    }

    func stop(serviceID: String) async throws -> ManagedServicesResponse {
        _ = try await runRaw(arguments: ["stop", serviceID])
        return try await statusAll()
    }

    func stopAllSync() {
        _ = try? runRawSync(arguments: ["stop-all"])
    }

    private func run(arguments: [String]) async throws -> ManagedServicesResponse {
        let data = try await runRaw(arguments: arguments)
        return try JSONDecoder().decode(ManagedServicesResponse.self, from: data)
    }

    private func runRaw(arguments: [String]) async throws -> Data {
        let script = scriptURL
        guard FileManager.default.isExecutableFile(atPath: script.path) else {
            throw ManagedServicesError.scriptNotFound(script.path)
        }

        return try await withCheckedThrowingContinuation { continuation in
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/bash")
            process.arguments = [script.path] + arguments
            process.currentDirectoryURL = RuntimePaths.repoRoot

            let outputPipe = Pipe()
            let errorPipe = Pipe()
            process.standardOutput = outputPipe
            process.standardError = errorPipe
            process.terminationHandler = { process in
                let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                if process.terminationStatus == 0 {
                    continuation.resume(returning: outputData)
                } else {
                    let message = String(decoding: errorData, as: UTF8.self)
                    continuation.resume(throwing: ManagedServicesError.commandFailed(message))
                }
            }

            do {
                try process.run()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func runRawSync(arguments: [String]) throws -> Data {
        let script = scriptURL
        guard FileManager.default.isExecutableFile(atPath: script.path) else {
            throw ManagedServicesError.scriptNotFound(script.path)
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        process.arguments = [script.path] + arguments
        process.currentDirectoryURL = RuntimePaths.repoRoot

        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        try process.run()
        process.waitUntilExit()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
        if process.terminationStatus != 0 {
            throw ManagedServicesError.commandFailed(String(decoding: errorData, as: UTF8.self))
        }
        return outputData
    }
}
