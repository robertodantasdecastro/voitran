enum SidebarSection: String, CaseIterable, Identifiable {
    case home = "Home"
    case session = "Session"
    case voiceLab = "Voice Lab"
    case settings = "Settings"
    case diagnostics = "Diagnostics"

    var id: String { rawValue }
}
