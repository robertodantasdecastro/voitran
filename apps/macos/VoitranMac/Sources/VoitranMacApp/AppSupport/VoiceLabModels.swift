import Foundation
import RealtimeCore

enum VoiceLabPhase: String {
    case idle
    case consentRequired = "consent-required"
    case readyToRecord = "ready-to-record"
    case recording
    case validating
    case profileBuilding = "profile-building"
    case readyForSynthesis = "ready-for-synthesis"
    case synthesizing
    case error
}

struct GuidedPhrase: Identifiable, Equatable {
    let id: String
    let locale: String
    let prompt: String
    let hint: String
}

struct RecordedVoiceSample: Identifiable, Equatable {
    let id: String
    let phrase: GuidedPhrase
    let url: URL
    let durationSeconds: Double
    let createdAt: Date
}

struct VoiceRuntimeHealth: Decodable, Equatable {
    let status: String
    let runtimeRoot: String
    let ready: Bool
    let preferredEngine: String
    let availableEngines: [String]
    let modelsFound: [String]
    let warnings: [String]
}

struct VoiceProfileInspection: Decodable, Equatable {
    let voiceProfile: VoiceProfile
}
