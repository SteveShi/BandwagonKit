import SwiftUI
import BandwagonCore

public struct NetworkView: View {
    public let manager: VPSManager
    @State private var showDeleteIPv6Confirm = false
    @State private var targetIPv6ToDelete: String?

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Network")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Manage IP addresses, IPv6 allocations, and network configurations.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // IP Addresses Card
                GlassCard {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Text("Allocated IP Addresses")
                                .font(.headline)

                            Spacer()

                            Button {
                                Task { await manager.addIPv6() }
                            } label: {
                                Label("Add IPv6", systemImage: "plus")
                            }
                            .buttonStyle(.bordered)
                        }

                        if let ips = manager.serviceInfo?.ipAddresses, !ips.isEmpty {
                            VStack(spacing: 8) {
                                ForEach(ips, id: \.self) { ip in
                                    HStack {
                                        Image(systemName: ip.contains(":") ? "network" : "globe")
                                            .foregroundStyle(.secondary)

                                        Text(ip)
                                            .font(.system(.body, design: .monospaced))

                                        Spacer()

                                        if ip.contains(":") {
                                            Button(role: .destructive) {
                                                targetIPv6ToDelete = ip
                                                showDeleteIPv6Confirm = true
                                            } label: {
                                                Image(systemName: "trash")
                                            }
                                            .buttonStyle(.plain)
                                            .foregroundStyle(.red)
                                        }
                                    }
                                    Divider()
                                }
                            }
                        } else {
                            Text("No IP addresses available.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(24)
        }
        .confirmationDialog(
            "Delete IPv6",
            isPresented: $showDeleteIPv6Confirm,
            titleVisibility: .visible
        ) {
            Button("Delete IPv6", role: .destructive) {
                if let ip = targetIPv6ToDelete {
                    Task { await manager.deleteIPv6(ip: ip) }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to release this IPv6 address?")
        }
    }
}
