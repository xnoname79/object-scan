import SwiftUI

struct ContentView: View {
    @State private var selectedTab: Tab = .scan

    enum Tab {
        case scan, gallery, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            ScanView()
                .tabItem {
                    Label("Scan", systemImage: "viewfinder")
                }
                .tag(Tab.scan)

            GalleryView()
                .tabItem {
                    Label("Gallery", systemImage: "cube.fill")
                }
                .tag(Tab.gallery)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(Tab.settings)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ScanManager())
}
