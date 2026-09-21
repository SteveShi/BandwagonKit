import SwiftUI
import BandwagonCore

public struct SystemView: View {
    public let manager: VPSManager
    @State private var newHostname = ""
    @State private var newPTR = ""
    @State private var selectedOS = ""
    @State private var showReinstallConfirmation = false
    @State private var showPasswordResetConfirmation = false

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("System")
                        .font(.system(.title, design: .rounded, weight: .bold))
                    Text("Configure server hostname, PTR records, root credentials, and operating system.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                // Hostname Card
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Set Hostname")
                            .font(.headline)

                        HStack(spacing: 12) {
                            TextField(manager.hostname, text: $newHostname)
                                .textFieldStyle(.roundedBorder)

                            Button("Save") {
                                guard !newHostname.isEmpty else { return }
                                Task { await manager.setHostname(newHostname) }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newHostname.isEmpty)
                        }
                    }
                }

                // PTR Record Card
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Set PTR Record")
                            .font(.headline)

                        HStack(spacing: 12) {
                            TextField("ptr.yourdomain.com", text: $newPTR)
                                .textFieldStyle(.roundedBorder)

                            Button("Save") {
                                guard !newPTR.isEmpty, let ip = manager.serviceInfo?.primaryIP else { return }
                                Task { await manager.setPTR(ip: ip, ptr: newPTR) }
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(newPTR.isEmpty)
                        }
                    }
                }

                // Reset Root Password
                GlassCard {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Reset Root Password")
                                .font(.headline)
                            Text("Generate a new root password and reboot the VPS.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button(role: .destructive) {
                            showPasswordResetConfirmation = true
                        } label: {
                            Text("Reset")
                        }
                        .buttonStyle(.bordered)
                    }
                }

                // Reinstall OS
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reinstall OS")
                            .font(.headline)

                        Text("Select a clean operating system template to reinstall.")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let templates = manager.availableOS?.templates, !templates.isEmpty {
                            HStack(spacing: 12) {
                                Picker("", selection: $selectedOS) {
                                    ForEach(templates, id: \.self) { tmpl in
                                        Text(tmpl).tag(tmpl)
                                    }
                                }
                                .labelsHidden()

                                Button(role: .destructive) {
                                    showReinstallConfirmation = true
                                } label: {
                                    Text("Reinstall OS")
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(.red)
                                .disabled(selectedOS.isEmpty)
                            }
                        } else {
                            Text("Loading templates…")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(24)
        }
        .task {
            await manager.loadAvailableOS()
            if let first = manager.availableOS?.templates?.first {
                selectedOS = first
            }
        }
        .confirmationDialog(
            "Reinstall OS",
            isPresented: $showReinstallConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reinstall OS", role: .destructive) {
                Task { await manager.reinstallOS(to: selectedOS) }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Reinstalling the OS will erase all current data on the disk. Proceed?")
        }
        .confirmationDialog(
            "Reset Root Password",
            isPresented: $showPasswordResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Password", role: .destructive) {
                Task { await manager.resetRootPassword() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will change your root password and restart the VPS.")
        }
    }
}
