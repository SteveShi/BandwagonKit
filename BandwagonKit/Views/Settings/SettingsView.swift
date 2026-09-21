import SwiftUI
import BandwagonCore

public struct SettingsView: View {
    @AppStorage("preferredTerminal") private var preferredTerminal: String = TerminalAppType.terminal.rawValue
    @AppStorage("autoRefreshInterval") private var autoRefreshInterval: Double = 30.0

    public init() {}

    public var body: some View {
        TabView {
            generalTab
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            aboutTab
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
        }
        .frame(width: 460, height: 260)
        .padding(20)
    }

    private var generalTab: some View {
        Form {
            Picker("Preferred Terminal", selection: $preferredTerminal) {
                ForEach(TerminalAppType.allCases) { terminal in
                    Text(terminal.rawValue).tag(terminal.rawValue)
                }
            }

            Picker("Auto-Refresh Interval", selection: $autoRefreshInterval) {
                Text("15 seconds").tag(15.0)
                Text("30 seconds").tag(30.0)
                Text("60 seconds").tag(60.0)
                Text("Disabled").tag(0.0)
            }
        }
        .padding()
    }

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "server.rack")
                .font(.system(size: 40))
                .foregroundStyle(.blue)

            Text("BandwagonKit")
                .font(.title2)
                .fontWeight(.bold)

            Text("Version 1.0 (Build 1)")
                .font(.caption)
                .foregroundStyle(.secondary)

            Button("Check for Updates…") {
                // Sparkle check for updates
                NotificationCenter.default.post(name: NSNotification.Name("CheckForUpdatesRequested"), object: nil)
            }
            .buttonStyle(.bordered)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
