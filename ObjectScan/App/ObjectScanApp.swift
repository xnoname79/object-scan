import SwiftUI

@main
struct ObjectScanApp: App {
    @StateObject private var scanManager = ScanManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(scanManager)
        }
    }
}
