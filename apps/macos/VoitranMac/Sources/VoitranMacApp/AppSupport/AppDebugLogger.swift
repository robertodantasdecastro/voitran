import Foundation

@MainActor
final class AppDebugLogger {
    static let shared = AppDebugLogger()

    private let fileManager = FileManager.default
    private let encoder = JSONEncoder()

    private init() {}

    var logFileURL: URL {
        RuntimePaths.appLogsDirectory.appendingPathComponent("voitran-macos.log")
    }

    func log(_ message: String, category: String = "app", metadata: [String: String] = [:]) {
        let event = LogEvent(
            timestamp: ISO8601DateFormatter().string(from: Date()),
            category: category,
            message: message,
            metadata: metadata
        )

        do {
            try fileManager.createDirectory(at: RuntimePaths.appLogsDirectory, withIntermediateDirectories: true)
            let data = try encoder.encode(event)
            if !fileManager.fileExists(atPath: logFileURL.path) {
                fileManager.createFile(atPath: logFileURL.path, contents: nil)
            }

            let handle = try FileHandle(forWritingTo: logFileURL)
            defer { try? handle.close() }
            try handle.seekToEnd()
            handle.write(data)
            handle.write(Data("\n".utf8))
        } catch {
            NSLog("Voitran logger failure: %@", error.localizedDescription)
        }
    }

    func readTail(lines: Int = 40) -> String {
        guard let data = try? Data(contentsOf: logFileURL),
              let content = String(data: data, encoding: .utf8) else {
            return "nenhum log disponivel"
        }

        return content
            .split(separator: "\n", omittingEmptySubsequences: false)
            .suffix(lines)
            .joined(separator: "\n")
    }

    func readCurrentSessionTail(lines: Int = 40) -> String {
        guard let data = try? Data(contentsOf: logFileURL),
              let content = String(data: data, encoding: .utf8) else {
            return "nenhum log disponivel"
        }

        let entries = content
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map(String.init)

        guard let lastLaunchIndex = entries.lastIndex(where: { entry in
            entry.contains("\"category\":\"lifecycle\"") && entry.contains("\"message\":\"app launch\"")
        }) else {
            return entries.suffix(lines).joined(separator: "\n")
        }

        return entries[lastLaunchIndex...]
            .suffix(lines)
            .joined(separator: "\n")
    }
}

private struct LogEvent: Encodable {
    let timestamp: String
    let category: String
    let message: String
    let metadata: [String: String]
}
