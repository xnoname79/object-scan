import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var scanManager: ScanManager
    @AppStorage("defaultExportFormat") private var defaultFormat: ExportFormat = .usdz
    @AppStorage("showMeshWireframe") private var showWireframe = false
    @AppStorage("autoSave") private var autoSave = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Scan Quality") {
                    Picker("Quality", selection: $scanManager.scanQuality) {
                        ForEach(ScanQuality.allCases, id: \.self) { quality in
                            VStack(alignment: .leading) {
                                Text(quality.rawValue)
                                Text(quality.description)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(quality)
                        }
                    }
                }

                Section("Export") {
                    Picker("Default Format", selection: $defaultFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                }

                Section("Display") {
                    Toggle("Show mesh wireframe", isOn: $showWireframe)
                    Toggle("Auto-save scans", isOn: $autoSave)
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Device", value: deviceInfo)
                }
            }
            .navigationTitle("Settings")
        }
    }

    private var deviceInfo: String {
        let device = UIDevice.current
        return "\(device.name) · iOS \(device.systemVersion)"
    }
}
