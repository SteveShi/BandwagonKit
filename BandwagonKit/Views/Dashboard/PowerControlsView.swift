import SwiftUI
import BandwagonCore

public struct PowerControlsView: View {
    public let manager: VPSManager
    @State private var showForceStopConfirmation = false

    public init(manager: VPSManager) {
        self.manager = manager
    }

    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text("Power Controls")
                        .font(.headline)

                    Spacer()

                    if manager.isPerformingAction {
                        ProgressView()
                            .controlSize(.small)
                    }
                }

                HStack(spacing: 12) {
                    // Start Button
                    Button {
                        Task { await manager.start() }
                    } label: {
                        Label("Start", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(manager.isRunning || manager.isPerformingAction)

                    // Stop Button
                    Button {
                        Task { await manager.stop() }
                    } label: {
                        Label("Stop", systemImage: "stop.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!manager.isRunning || manager.isPerformingAction)

                    // Restart Button
                    Button {
                        Task { await manager.restart() }
                    } label: {
                        Label("Restart", systemImage: "arrow.clockwise")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(!manager.isRunning || manager.isPerformingAction)

                    // Force Stop Button
                    Button(role: .destructive) {
                        showForceStopConfirmation = true
                    } label: {
                        Label("Force Stop", systemImage: "bolt.slash.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    .disabled(!manager.isRunning || manager.isPerformingAction)
                }
                .controlSize(.regular)
            }
        }
        .confirmationDialog(
            "Force Stop VPS",
            isPresented: $showForceStopConfirmation,
            titleVisibility: .visible
        ) {
            Button("Force Stop", role: .destructive) {
                Task { await manager.forceStop() }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Force stop may cause unsaved data loss. Are you sure?")
        }
    }
}
