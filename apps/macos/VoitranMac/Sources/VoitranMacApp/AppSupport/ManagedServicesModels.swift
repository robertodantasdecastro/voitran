import Foundation

struct ManagedServicesResponse: Decodable, Sendable {
    let services: [ManagedServiceStatus]
}

struct ManagedServiceStatus: Decodable, Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let kind: String
    let status: String
    let pid: Int?
    let host: String?
    let port: Int?
    let logPath: String?
    let script: String?
    let available: Bool?
    let statusDetail: String?
    let installMode: String?
    let managedOnLaunch: Bool?
    let managedOnExit: Bool?
    let runtimeHealth: VoiceRuntimeHealth?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case kind
        case status
        case pid
        case host
        case port
        case logPath = "log_path"
        case script
        case available
        case statusDetail = "status_detail"
        case installMode = "install_mode"
        case managedOnLaunch = "managed_on_launch"
        case managedOnExit = "managed_on_exit"
        case runtimeHealth = "runtime_health"
    }
}
