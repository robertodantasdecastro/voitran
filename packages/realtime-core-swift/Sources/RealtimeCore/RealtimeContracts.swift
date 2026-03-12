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
    public let source: String
    public let scope: String
    public let expiresAt: String
    public let approvedLocales: [String]
    public let hash: String
    public let revocationPolicy: String

    public init(
        voiceIdentityID: String,
        owner: String,
        source: String,
        scope: String,
        expiresAt: String,
        approvedLocales: [String],
        hash: String,
        revocationPolicy: String
    ) {
        self.voiceIdentityID = voiceIdentityID
        self.owner = owner
        self.source = source
        self.scope = scope
        self.expiresAt = expiresAt
        self.approvedLocales = approvedLocales
        self.hash = hash
        self.revocationPolicy = revocationPolicy
    }
}

public struct VoiceIdentityPolicy: Sendable, Codable, Equatable {
    public let requiresConsent: Bool
    public let approvedLocales: [String]
    public let expiresAt: String?
    public let retentionPolicy: String

    public init(
        requiresConsent: Bool,
        approvedLocales: [String],
        expiresAt: String? = nil,
        retentionPolicy: String = "local-user-managed"
    ) {
        self.requiresConsent = requiresConsent
        self.approvedLocales = approvedLocales
        self.expiresAt = expiresAt
        self.retentionPolicy = retentionPolicy
    }

    public func allows(locale: String) -> Bool {
        approvedLocales.contains(locale)
    }
}

public struct VoiceProfile: Sendable, Codable, Equatable, Identifiable {
    public let id: String
    public let ownerLocalID: String
    public let locale: String
    public let approvedLocales: [String]
    public let createdAt: String
    public let expiresAt: String
    public let consentManifestPath: String
    public let samplePaths: [String]
    public let status: String
    public let engine: String
    public let warnings: [String]

    public init(
        id: String,
        ownerLocalID: String,
        locale: String,
        approvedLocales: [String],
        createdAt: String,
        expiresAt: String,
        consentManifestPath: String,
        samplePaths: [String],
        status: String,
        engine: String,
        warnings: [String]
    ) {
        self.id = id
        self.ownerLocalID = ownerLocalID
        self.locale = locale
        self.approvedLocales = approvedLocales
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.consentManifestPath = consentManifestPath
        self.samplePaths = samplePaths
        self.status = status
        self.engine = engine
        self.warnings = warnings
    }
}

public struct VoiceEnrollmentRequest: Sendable, Codable, Equatable {
    public let ownerLocalID: String
    public let locale: String
    public let approvedLocales: [String]
    public let samplePaths: [String]
    public let consentManifestPath: String

    public init(
        ownerLocalID: String,
        locale: String,
        approvedLocales: [String],
        samplePaths: [String],
        consentManifestPath: String
    ) {
        self.ownerLocalID = ownerLocalID
        self.locale = locale
        self.approvedLocales = approvedLocales
        self.samplePaths = samplePaths
        self.consentManifestPath = consentManifestPath
    }

    enum CodingKeys: String, CodingKey {
        case ownerLocalID = "owner_local_id"
        case locale
        case approvedLocales = "approved_locales"
        case samplePaths = "sample_paths"
        case consentManifestPath = "consent_manifest_path"
    }
}

public struct VoiceEnrollmentResult: Sendable, Codable, Equatable {
    public let voiceProfile: VoiceProfile
    public let totalDurationSeconds: Double
    public let latencyMilliseconds: Int
    public let warnings: [String]

    public init(
        voiceProfile: VoiceProfile,
        totalDurationSeconds: Double,
        latencyMilliseconds: Int,
        warnings: [String]
    ) {
        self.voiceProfile = voiceProfile
        self.totalDurationSeconds = totalDurationSeconds
        self.latencyMilliseconds = latencyMilliseconds
        self.warnings = warnings
    }
}

public struct VoiceSynthesisRequest: Sendable, Codable, Equatable {
    public let text: String
    public let voiceProfileID: String
    public let locale: String

    public init(text: String, voiceProfileID: String, locale: String) {
        self.text = text
        self.voiceProfileID = voiceProfileID
        self.locale = locale
    }

    enum CodingKeys: String, CodingKey {
        case text
        case voiceProfileID = "voice_profile_id"
        case locale
    }
}

public struct VoiceSynthesisResult: Sendable, Codable, Equatable {
    public let voiceProfileID: String
    public let locale: String
    public let outputAudioPath: String
    public let latencyMilliseconds: Int
    public let engine: String
    public let warnings: [String]

    public init(
        voiceProfileID: String,
        locale: String,
        outputAudioPath: String,
        latencyMilliseconds: Int,
        engine: String,
        warnings: [String]
    ) {
        self.voiceProfileID = voiceProfileID
        self.locale = locale
        self.outputAudioPath = outputAudioPath
        self.latencyMilliseconds = latencyMilliseconds
        self.engine = engine
        self.warnings = warnings
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

public protocol VoiceCloneEngine: Sendable {
    var id: String { get }
    func cloneVoice(from request: VoiceEnrollmentRequest) async throws -> VoiceEnrollmentResult
    func speak(request: VoiceSynthesisRequest) async throws -> VoiceSynthesisResult
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
