import SwiftUI
import BandwagonCore

public struct SnapshotsView: View {
    public let manager: VPSManager
    @State private var showCreateSheet = false
    @State private var snapshotDescription = ""
    @State private var snapshotToRestore: String?
    @State private var showRestoreConfirmation = false

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Snapshots")
                            .font(.system(.title, design: .rounded, weight: .bold))
                        Text("Manage backups and point-in-time images of your VPS disk.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        showCreateSheet = true
                    } label: {
                        Label("Create Snapshot", systemImage: "camera.fill")
                    }
                    .buttonStyle(.borderedProminent)
                }

                if manager.snapshots.isEmpty {
                    GlassCard {
                        VStack(spacing: 12) {
                            Image(systemName: "camera.badge.ellipsis")
                                .font(.system(size: 36))
                                .foregroundStyle(.secondary)
                            Text("No snapshots available")
                                .font(.headline)
                            Text("Create a snapshot to backup your entire server disk state.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    }
                } else {
                    ForEach(manager.snapshots) { item in
                        GlassCard {
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text(item.fileName)
                                        .font(.headline)

                                    HStack(spacing: 12) {
                                        if let size = item.size {
                                            Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        if let os = item.os {
                                            Text(os)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        if let desc = item.description, !desc.isEmpty {
                                            Text(desc)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }

                                Spacer()

                                HStack(spacing: 12) {
                                    Button {
                                        snapshotToRestore = item.fileName
                                        showRestoreConfirmation = true
                                    } label: {
                                        Text("Restore")
                                    }
                                    .buttonStyle(.bordered)

                                    Button(role: .destructive) {
                                        Task { await manager.deleteSnapshot(key: item.fileName) }
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .task {
            await manager.loadSnapshots()
        }
        .sheet(isPresented: $showCreateSheet) {
            VStack(spacing: 18) {
                Text("Create Snapshot")
                    .font(.headline)

                TextField("Description (Optional)", text: $snapshotDescription)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    Button("Cancel") {
                        showCreateSheet = false
                    }
                    Spacer()
                    Button("Create") {
                        let desc = snapshotDescription
                        showCreateSheet = false
                        Task { await manager.createSnapshot(description: desc) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding(24)
            .frame(width: 380)
        }
        .confirmationDialog(
            "Restore Snapshot",
            isPresented: $showRestoreConfirmation,
            titleVisibility: .visible
        ) {
            Button("Restore", role: .destructive) {
                if let key = snapshotToRestore {
                    Task { await manager.restoreSnapshot(key: key) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Restoring a snapshot will overwrite the current VPS disk. Proceed?")
        }
    }
}
