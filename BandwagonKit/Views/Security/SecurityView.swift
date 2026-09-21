import SwiftUI
import BandwagonCore

public struct SecurityView: View {
    public let manager: VPSManager

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Security & Logs")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Audit trail, registered SSH keys, and API rate limits.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Rate Limit Status
                if let rate = manager.rateLimitStatus {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("API Rate Limit Status")
                                .font(.headline)

                            HStack(spacing: 24) {
                                VStack(alignment: .leading) {
                                    Text("Points (15 min)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(rate.remainingPoints15Min ?? 0)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }

                                VStack(alignment: .leading) {
                                    Text("Points (24 h)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("\(rate.remainingPoints24H ?? 0)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                    }
                }

                // SSH Keys
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Registered SSH Keys")
                            .font(.headline)

                        if manager.sshKeys.isEmpty {
                            Text("No SSH keys registered.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(manager.sshKeys) { key in
                                HStack {
                                    Image(systemName: "key.fill")
                                        .foregroundStyle(.secondary)
                                    Text(key.name ?? "Public Key")
                                        .font(.subheadline)
                                    Spacer()
                                    Text(String(key.key.prefix(20)) + "…")
                                        .font(.system(.caption, design: .monospaced))
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                // Audit Log
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Audit Log")
                            .font(.headline)

                        if manager.auditLogs.isEmpty {
                            Text("No recent audit log entries.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(manager.auditLogs) { log in
                                    HStack {
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(log.type ?? "Action")
                                                .font(.subheadline)
                                                .fontWeight(.medium)

                                            if let details = log.details {
                                                Text(details)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(log.ip ?? "—")
                                                .font(.system(.caption, design: .monospaced))
                                                .foregroundStyle(.secondary)

                                            Text(log.date.formatted(date: .numeric, time: .shortened))
                                                .font(.caption2)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                    Divider()
                                }
                            }
                        }
                    }
                }
            }
            .padding(24)
        }
        .task {
            await manager.loadRateLimitStatus()
            await manager.loadSshKeys()
            await manager.loadAuditLogs()
        }
    }
}
