import SwiftUI
import BandwagonCore

public struct DashboardView: View {
    public let manager: VPSManager

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Banner
                headerView

                // Error / Feedback Banner
                if let error = manager.errorMessage {
                    feedbackBanner(text: error, isError: true)
                } else if let feedback = manager.actionFeedbackMessage {
                    feedbackBanner(text: feedback, isError: false)
                }

                // Resource Gauges Grid (2x2)
                LazyVGrid(columns: [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)], spacing: 16) {
                    ResourceGaugeCardView(
                        titleKey: "CPU Load",
                        icon: "cpu",
                        percentage: manager.cpuUsagePercentage,
                        detailText: cpuDetailText,
                        accentColor: .cyan
                    )

                    ResourceGaugeCardView(
                        titleKey: "Memory (RAM)",
                        icon: "memorychip",
                        percentage: manager.memoryUsagePercentage,
                        detailText: manager.memoryUsageDescription,
                        accentColor: .blue
                    )

                    ResourceGaugeCardView(
                        titleKey: "Disk Usage",
                        icon: "internaldrive",
                        percentage: manager.diskUsagePercentage,
                        detailText: manager.diskUsageDescription,
                        accentColor: .indigo
                    )

                    ResourceGaugeCardView(
                        titleKey: "Bandwidth Usage",
                        icon: "arrow.up.arrow.down.circle",
                        percentage: manager.bandwidthUsagePercentage,
                        detailText: manager.bandwidthUsageDescription,
                        accentColor: .teal
                    )
                }

                // Power Controls
                PowerControlsView(manager: manager)

                // Server Details
                VPSInfoCardView(manager: manager)
            }
            .padding(24)
        }
        .task {
            if manager.serviceInfo == nil {
                await manager.refreshAll()
            }
        }
    }

    private var headerView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 12) {
                    Text(manager.account.name)
                        .font(.system(.title, design: .rounded, weight: .bold))

                    StatusBadge(
                        isRunning: manager.isRunning,
                        isSuspended: manager.serviceInfo?.suspended ?? false
                    )
                }

                HStack(spacing: 8) {
                    Text("VEID: \(manager.account.veid)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if let lastUpdated = manager.lastUpdated {
                        Text("•")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: NSLocalizedString("Last updated: %@", comment: ""), lastUpdated.formatted(date: .omitted, time: .standard)))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            Button {
                Task { await manager.refreshAll() }
            } label: {
                if manager.isRefreshing {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
            }
            .buttonStyle(.bordered)
            .disabled(manager.isRefreshing)
        }
    }

    private var cpuDetailText: String {
        guard manager.liveInfo != nil else { return "—" }
        if manager.isCpuThrottled {
            return String(format: NSLocalizedString("Throttled • Load: %@", comment: ""), manager.cpuUsageDescription)
        } else if (manager.liveInfo?.load1Min ?? 0) == 0 {
            return String(format: NSLocalizedString("Load: %@ (Idle)", comment: ""), manager.cpuUsageDescription)
        } else {
            return String(format: NSLocalizedString("Load: %@", comment: ""), manager.cpuUsageDescription)
        }
    }

    private func feedbackBanner(text: String, isError: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isError ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundStyle(isError ? .red : .green)

            Text(text)
                .font(.subheadline)
                .foregroundStyle(isError ? .red : .primary)

            Spacer()
        }
        .padding(12)
        .background(isError ? Color.red.opacity(0.1) : Color.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
