import SwiftUI
import BandwagonCore

@main
struct BandwagonKitApp: App {
    @State private var accountStore = AccountStore()
    @State private var activeManager: VPSManager?
    @State private var pollingService = PollingService()
    @State private var showWhatsNewSheet: Bool = false

    @AppStorage("autoRefreshInterval") private var autoRefreshInterval: Double = 30.0

    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                SidebarView(accountStore: accountStore, activeManager: $activeManager)
                    .navigationSplitViewColumnWidth(min: 220, ideal: 260, max: 320)
            } detail: {
                MainContentView(manager: activeManager)
            }
            .sheet(isPresented: $showWhatsNewSheet) {
                WhatsNewSheetView()
            }
            .onChange(of: activeManager?.id) { _, _ in
                restartPolling()
            }
            .onChange(of: autoRefreshInterval) { _, _ in
                restartPolling()
            }
            .onAppear {
                restartPolling()
            }
        }
        .commands {
            // About menu additions: only system About and Sparkle "Check for Updates…"
            CommandGroup(after: .appInfo) {
                Button("Check for Updates…") {
                    NotificationCenter.default.post(name: NSNotification.Name("CheckForUpdatesRequested"), object: nil)
                }
            }

            // Help menu: WhatsNewSheetView entry exclusively here
            CommandGroup(replacing: .help) {
                Button("What's New in BandwagonKit") {
                    showWhatsNewSheet = true
                }
            }
        }

        Settings {
            SettingsView()
        }
    }

    private func restartPolling() {
        pollingService.stopPolling()
        guard let manager = activeManager, autoRefreshInterval > 0 else { return }
        pollingService.intervalSeconds = autoRefreshInterval
        pollingService.isEnabled = true
        pollingService.startPolling(with: manager)
    }
}
