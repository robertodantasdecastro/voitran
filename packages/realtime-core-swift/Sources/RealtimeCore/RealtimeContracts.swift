public struct CapabilityProfile: Sendable, Codable, Equatable {
    public let deviceClass: String
    public let supportedLocales: [String]
    public let canRunFullLocalVoice: Bool

    public init(deviceClass: String, supportedLocales: [String], canRunFullLocalVoice: Bool) {
        self.deviceClass = deviceClass
        self.supportedLocales = supportedLocales
        self.canRunFullLocalVoice = canRunFullLocalVoice
    }
}

public struct ConsentManifest: Sendable, Codable, Equatable {
    public let voiceIdentityID: String
    public let owner: String
    public let scope: String
    public let expiresAt: String

    public init(voiceIdentityID: String, owner: String, scope: String, expiresAt: String) {
        self.voiceIdentityID = voiceIdentityID
        self.owner = owner
        self.scope = scope
        self.expiresAt = expiresAt
    }
}

public struct VoiceIdentityPolicy: Sendable, Codable, Equatable {
    public let requiresConsent: Bool
    public let approvedLocales: [String]

    public init(requiresConsent: Bool, approvedLocales: [String]) {
        self.requiresConsent = requiresConsent
        self.approvedLocales = approvedLocales
    }
}

public protocol SpeechRecognizer: Sendable {
    var id: String { get }
    func start() async throws
    func stop() async throws
}

public protocol TranslationEngine: Sendable {
    var id: String { get }
    func translate(text: String, from sourceLocale: String, to targetLocale: String) async throws -> String
}

public protocol SpeechSynthesizer: Sendable {
    var id: String { get }
    func speak(text: String, locale: String) async throws
}

public protocol TransportSession: Sendable {
    var sessionID: String { get }
    func connect() async throws
    func disconnect() async throws
}

public protocol ConversationOrchestrator: Sendable {
    func startSession(with capabilityProfile: CapabilityProfile) async throws
    func stopSession() async throws
}
