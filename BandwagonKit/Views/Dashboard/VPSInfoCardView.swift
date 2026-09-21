import SwiftUI
import BandwagonCore

public struct VPSInfoCardView: View {
    public let manager: VPSManager
    @State private var hasCopiedIP = false
    @AppStorage("preferredTerminal") private var preferredTerminal: String = TerminalAppType.terminal.rawValue

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 16) {
                // Header with actions
                HStack {
                    Text("Server Details")
                        .font(.headline)

                    Spacer()

                    // Quick SSH launcher
                    Menu {
                        ForEach(TerminalAppType.allCases) { terminal in
                            Button {
                                preferredTerminal = terminal.rawValue
                                launchSSH(with: terminal)
                            } label: {
                                HStack {
                                    Text(terminal.rawValue)
                                    if preferredTerminal == terminal.rawValue {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Label("Open SSH", systemImage: "terminal.fill")
                    } primaryAction: {
                        let current = TerminalAppType(rawValue: preferredTerminal) ?? .terminal
                        launchSSH(with: current)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                }

                Divider()

                // Key-Value Grid
                Grid(alignment: .leading, horizontalSpacing: 24, verticalSpacing: 12) {
                    GridRow {
                        infoLabel("IP Address")
                        HStack(spacing: 8) {
                            Text(manager.ipAddress)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.medium)

                            Button {
                                NSPasteboard.general.clearContents()
                                NSPasteboard.general.setString(manager.ipAddress, forType: .string)
                                hasCopiedIP = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    hasCopiedIP = false
                                }
                            } label: {
                                Image(systemName: hasCopiedIP ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundStyle(hasCopiedIP ? .green : .secondary)
                            }
                            .buttonStyle(.plain)
                            .help(hasCopiedIP ? "Copied" : "Copy IP")
                        }
                    }

                    GridRow {
                        infoLabel("Location")
                        Text(manager.nodeLocation)
                            .font(.body)
                    }

                    GridRow {
                        infoLabel("Operating System")
                        Text(manager.osName)
                            .font(.body)
                    }

                    GridRow {
                        infoLabel("Hostname")
                        Text(manager.hostname)
                            .font(.body)
                    }

                    GridRow {
                        infoLabel("SSH Port")
                        Text("\(manager.sshPort)")
                            .font(.system(.body, design: .monospaced))
                    }
                }
            }
        }
    }

    private func infoLabel(_ key: LocalizedStringKey) -> some View {
        Text(key)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(width: 140, alignment: .leading)
    }

    private func launchSSH(with terminal: TerminalAppType) {
        guard manager.ipAddress != "—" else { return }
        TerminalLauncher.shared.launchSSH(
            host: manager.ipAddress,
            port: manager.sshPort,
            user: "root",
            terminal: terminal
        )
    }
}
