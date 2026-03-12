import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Toggle("Priorizar pipeline local", isOn: .constant(true))
            Toggle("Permitir degradacao para legenda traduzida", isOn: .constant(true))
            Toggle("Exigir consentimento de voz", isOn: .constant(true))
            Toggle(
                "Modo debug do app",
                isOn: Binding(
                    get: { model.debugModeEnabled },
                    set: { model.setDebugMode(enabled: $0) }
                )
            )
            Divider()
            Text("Runtime")
                .font(.title3.bold())
            Text("Path do runtime: \(RuntimePaths.runtimeRoot.path)")
            Text("Logs do app: \(RuntimePaths.appLogsDirectory.appendingPathComponent("voitran-macos.log").path)")
            Text("Idiomas aprovados: \(model.voicePolicy.approvedLocales.joined(separator: ", "))")
            Text("Retencao local: \(model.voicePolicy.retentionPolicy)")
            Text("Script de servicos: \(RuntimePaths.servicesScript.path)")
            Button("Bootstrap do runtime") {
                Task { await model.bootstrapRuntime() }
            }
            Button("Atualizar logs") {
                model.refreshDebugLogTail()
            }
            Divider()
            Text("Servicos dependentes")
                .font(.title3.bold())
            HStack {
                Button("Iniciar todos") {
                    Task { await model.startManagedDependencies() }
                }
                Button("Encerrar todos") {
                    Task { await model.stopManagedDependencies() }
                }
                Button("Atualizar status") {
                    Task { await model.refreshManagedServices() }
                }
            }
            ForEach(model.managedServices) { service in
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(service.name) (\(service.kind))")
                        .font(.headline)
                    Text("Status: \(service.status)")
                    if let port = service.port, let host = service.host {
                        Text("Endereco: \(host):\(port)")
                    }
                    if let logPath = service.logPath {
                        Text("Log: \(logPath)")
                    }
                    if let script = service.script {
                        Text("Script: \(script)")
                    }
                    HStack {
                        Button("Iniciar") {
                            Task { await model.startService(id: service.id) }
                        }
                        Button("Encerrar") {
                            Task { await model.stopService(id: service.id) }
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            Divider()
            Text("Instalacao")
                .font(.title3.bold())
            Text("Bundle release: `dist/VoitranMac.app`")
            Text("Pacote/zip: `bash scripts/package_voitran_macos.sh`")
            Text("Instalador local: `bash scripts/install_voitran_macos.sh`")
            Button("Apagar perfil local atual") {
                Task { await model.revokeCurrentProfile() }
            }
            .disabled(model.currentProfile == nil)
            Spacer()
        }
        .padding(24)
    }
}
