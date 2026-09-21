import SwiftUI
import BandwagonCore

public struct MigrationView: View {
    public let manager: VPSManager
    @State private var selectedLocation: String?
    @State private var showMigrationConfirmation = false

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Migration")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Transfer your VPS and IP to a different data center facility.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let current = manager.migrationLocations?.currentLocation {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Current Location")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text(manager.migrationLocations?.descriptions?[current] ?? current)
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                    }
                }

                Text("Available Destinations")
                    .font(.headline)
                    .padding(.top, 8)

                if let locations = manager.migrationLocations?.locationItems, !locations.isEmpty {
                    VStack(spacing: 12) {
                        ForEach(locations) { item in
                            GlassCard {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.body)
                                            .fontWeight(item.isCurrent ? .bold : .regular)

                                        Text(item.id)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    if item.isCurrent {
                                        Text("Current")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(Color.green.opacity(0.15), in: Capsule())
                                            .foregroundStyle(.green)
                                    } else {
                                        Button("Migrate") {
                                            selectedLocation = item.id
                                            showMigrationConfirmation = true
                                        }
                                        .buttonStyle(.bordered)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    GlassCard {
                        Text("No migration facilities available for this plan.")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(24)
        }
        .task {
            await manager.loadMigrationLocations()
        }
        .confirmationDialog(
            "Confirm Migration",
            isPresented: $showMigrationConfirmation,
            titleVisibility: .visible
        ) {
            Button("Start Migration", role: .destructive) {
                if let loc = selectedLocation {
                    Task { await manager.startMigration(to: loc) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Migrating will temporarily stop the VPS and transfer data to the selected facility. Proceed?")
        }
    }
}
