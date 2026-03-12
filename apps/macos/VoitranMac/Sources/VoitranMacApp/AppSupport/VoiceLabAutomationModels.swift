import Foundation
import RealtimeCore

struct VoiceLabCapturedSample: Decodable, Identifiable, Equatable {
    let phraseID: String
    let locale: String
    let path: String
    let durationSeconds: Double
    let modifiedAt: String

    var id: String { path }

    enum CodingKeys: String, CodingKey {
        case phraseID
        case locale
        case path
        case durationSeconds
        case modifiedAt
    }
}

struct VoiceLabSampleSummary: Decodable, Equatable {
    let samples: [VoiceLabCapturedSample]
    let totalDurationSeconds: Double
    let ready: Bool
    let warnings: [String]
}

struct VoiceLabTrainingReport: Decodable, Equatable {
    let status: String
    let sampleSummary: VoiceLabSampleSummary
    let enrollment: VoiceEnrollmentResult
    let consentManifestPath: String
}

struct VoiceLabSmokeReport: Decodable, Equatable {
    let status: String
    let health: VoiceRuntimeHealth
    let sampleSummary: VoiceLabSampleSummary
    let enrollment: VoiceEnrollmentResult
    let synthesis: VoiceSynthesisResult
    let reportPath: String
}
