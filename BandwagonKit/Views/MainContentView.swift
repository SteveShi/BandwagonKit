import SwiftUI
import BandwagonCore

public enum ServerTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case snapshots = "Snapshots"
    case migration = "Migration"
    case system = "System"
    case network = "Network"
    case security = "Security & Logs"

    public var id: String { rawValue }

    public var icon: String {
        switch self {
        case .dashboard: return "gauge.with.needle"
        case .snapshots: return "camera"
        case .migration: return "arrow.left.arrow.right"
        case .system: return "gearshape.2"
        case .network: return "network"
        case .security: return "shield.checkered"
        }
    }
}

public struct MainContentView: View {
    public let manager: VPSManager?
    @State private var selectedTab: ServerTab = .dashboard

    public init(manager: VPSManager?) {
        self.manager = manager
    }

    public var body: some View {
        if let manager {
            VStack(spacing: 0) {
                // Tab Selection Bar with Liquid Glass aesthetic
                HStack(spacing: 8) {
                    ForEach(ServerTab.allCases) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                Text(LocalizedStringKey(tab.rawValue))
                            }
                            .font(.subheadline)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                selectedTab == tab ? Color.accentColor.opacity(0.15) : Color.clear,
                                in: RoundedRectangle(cornerRadius: 8, style: .continuous)
                            )
                            .foregroundStyle(selectedTab == tab ? Color.accentColor : Color.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(.bar)

                Divider()

                // Active View
                Group {
                    switch selectedTab {
                    case .dashboard:
                        DashboardView(manager: manager)
                    case .snapshots:
                        SnapshotsView(manager: manager)
                    case .migration:
                        MigrationView(manager: manager)
                    case .system:
                        SystemView(manager: manager)
                    case .network:
                        NetworkView(manager: manager)
                    case .security:
                        SecurityView(manager: manager)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        } else {
            ContentUnavailableView {
                Label("No Server Selected", systemImage: "server.rack")
            } description: {
                Text("Select a VPS from the sidebar or click + to add a new server.")
            }
        }
    }
}
