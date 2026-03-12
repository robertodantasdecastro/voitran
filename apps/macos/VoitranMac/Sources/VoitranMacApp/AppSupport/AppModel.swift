import SwiftUI
import RealtimeCore

@MainActor
final class AppModel: ObservableObject {
    @Published var sessionStatus = "idle"
    @Published var targetLocale = "en"
    @Published var sourceLocale = "pt-BR"
    @Published var voicePolicy = VoiceIdentityPolicy(requiresConsent: true, approvedLocales: ["pt-BR", "en"])

    let capabilityProfile = CapabilityProfile(
        deviceClass: "mac-apple-silicon",
        supportedLocales: ["pt-BR", "en"],
        canRunFullLocalVoice: true
    )
}
