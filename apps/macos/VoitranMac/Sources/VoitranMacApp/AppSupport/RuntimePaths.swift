import Foundation

enum RuntimePaths {
    static let runtimeRoot = URL(fileURLWithPath: "/Volumes/SSDExterno/Voitran_runtime", isDirectory: true)

    static var supportRoot: URL {
        if let bundled = bundledSupportRoot {
            return bundled
        }
        return repoRoot
    }

    static var bundledSupportRoot: URL? {
        guard let resourceURL = Bundle.main.resourceURL else {
            return nil
        }

        let scriptsDirectory = resourceURL.appendingPathComponent("scripts", isDirectory: true)
        if FileManager.default.fileExists(atPath: scriptsDirectory.path) {
            return resourceURL
        }

        return nil
    }

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
        supportRoot.appendingPathComponent("scripts/voice_runtime.sh")
    }

    static var servicesScript: URL {
        supportRoot.appendingPathComponent("scripts/voitran_services.sh")
    }

    static var bootstrapScript: URL {
        supportRoot.appendingPathComponent("scripts/bootstrap_voice_runtime.sh")
    }

    static var workingDirectory: URL {
        supportRoot
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
