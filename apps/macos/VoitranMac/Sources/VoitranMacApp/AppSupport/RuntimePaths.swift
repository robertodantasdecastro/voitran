import Foundation

enum RuntimePaths {
    static let runtimeRoot = URL(fileURLWithPath: "/Volumes/SSDExterno/Voitran_runtime", isDirectory: true)

    static var repoRoot: URL {
        let fileManager = FileManager.default
        var candidate = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)

        for _ in 0..<8 {
            let marker = candidate.appendingPathComponent("AGENTS.md")
            if fileManager.fileExists(atPath: marker.path) {
                return candidate
            }

            let scripts = candidate.appendingPathComponent("scripts/voice_runtime.sh")
            if fileManager.fileExists(atPath: scripts.path) {
                return candidate
            }

            candidate.deleteLastPathComponent()
        }

        return URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
    }

    static var sidecarScript: URL {
        repoRoot.appendingPathComponent("scripts/voice_runtime.sh")
    }

    static var servicesScript: URL {
        repoRoot.appendingPathComponent("scripts/voitran_services.sh")
    }

    static var bootstrapScript: URL {
        repoRoot.appendingPathComponent("scripts/bootstrap_voice_runtime.sh")
    }

    static var samplesDirectory: URL {
        runtimeRoot.appendingPathComponent("voices/samples", isDirectory: true)
    }

    static var consentsDirectory: URL {
        runtimeRoot.appendingPathComponent("voices/consents", isDirectory: true)
    }

    static var profilesDirectory: URL {
        runtimeRoot.appendingPathComponent("voices/profiles", isDirectory: true)
    }

    static var outputsDirectory: URL {
        runtimeRoot.appendingPathComponent("voices/outputs", isDirectory: true)
    }
}
