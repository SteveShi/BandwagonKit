import SwiftUI
import BandwagonCore

public struct StatusBadge: View {
    public let isRunning: Bool
    public let isSuspended: Bool

    public init(isRunning: Bool, isSuspended: Bool = false) {
        self.isRunning = isRunning
        self.isSuspended = isSuspended
    }

    public var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
                .shadow(color: statusColor.opacity(0.6), radius: 4, x: 0, y: 0)

            Text(statusTextKey)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(statusColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(statusColor.opacity(0.12), in: Capsule())
    }

    private var statusColor: Color {
        if isSuspended { return .orange }
        return isRunning ? .green : .red
    }

    private var statusTextKey: LocalizedStringKey {
        if isSuspended { return "Suspended" }
        return isRunning ? "Running" : "Stopped"
    }
}
