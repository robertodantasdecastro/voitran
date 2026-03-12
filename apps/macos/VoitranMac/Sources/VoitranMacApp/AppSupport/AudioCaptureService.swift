import AVFoundation
import Foundation

enum AudioCaptureError: LocalizedError {
    case permissionDenied
    case recorderUnavailable
    case notRecording

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            "permissao de microfone negada"
        case .recorderUnavailable:
            "nao foi possivel inicializar a gravacao local"
        case .notRecording:
            "nenhuma gravacao em andamento"
        }
    }
}

@MainActor
final class AudioCaptureService: NSObject {
    private var recorder: AVAudioRecorder?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .audio) { granted in
                continuation.resume(returning: granted)
            }
        }
    }

    func startRecording(to url: URL) throws {
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 22_050,
            AVNumberOfChannelsKey: 1,
            AVLinearPCMBitDepthKey: 16,
            AVLinearPCMIsFloatKey: false,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        guard let recorder else {
            throw AudioCaptureError.recorderUnavailable
        }

        recorder.isMeteringEnabled = true
        recorder.record()
    }

    func stopRecording() throws -> Double {
        guard let recorder else {
            throw AudioCaptureError.notRecording
        }

        recorder.stop()
        let duration = recorder.currentTime
        self.recorder = nil
        return duration
    }

    func currentPowerLevel() -> Double {
        guard let recorder else {
            return 0
        }

        recorder.updateMeters()
        let averagePower = Double(recorder.averagePower(forChannel: 0))
        return max(0, min(1, (averagePower + 60) / 60))
    }
}
