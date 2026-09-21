import SwiftUI

public struct WhatsNewFeatureItem: Identifiable, Sendable {
    public var id: String { titleKey }
    public let icon: String
    public let iconColor: Color
    public let titleKey: String
    public let descriptionKey: String

    public init(icon: String, iconColor: Color, titleKey: String, descriptionKey: String) {
        self.icon = icon
        self.iconColor = iconColor
        self.titleKey = titleKey
        self.descriptionKey = descriptionKey
    }
}

public struct WhatsNewSheetView: View {
    @Environment(\.dismiss) private var dismiss

    private let features: [WhatsNewFeatureItem] = [
        WhatsNewFeatureItem(
            icon: "sparkles",
            iconColor: .cyan,
            titleKey: "Liquid Glass UI",
            descriptionKey: "Crafted specifically for macOS 26 Tahoe with depth, translucency, and fluid interactions."
        ),
        WhatsNewFeatureItem(
            icon: "server.rack",
            iconColor: .blue,
            titleKey: "Multi-VPS Management",
            descriptionKey: "Monitor multiple BandwagonHost servers with real-time status and usage gauges."
        ),
        WhatsNewFeatureItem(
            icon: "terminal.fill",
            iconColor: .green,
            titleKey: "One-Click SSH",
            descriptionKey: "Seamlessly launch your favorite terminal: Terminal.app, iTerm2, Ghostty, or MacSSH."
        )
    ]

    public init() {}

    public var body: some View {
        VStack(spacing: 28) {
            // Header
            VStack(spacing: 8) {
                Image(systemName: "server.rack")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(.linearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .padding(.bottom, 4)

                Text("What's New in BandwagonKit")
                    .font(.system(size: 24, weight: .bold, design: .rounded))

                Text("Version 1.0 (Tahoe Edition)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 12)

            // Features list
            VStack(alignment: .leading, spacing: 20) {
                ForEach(features) { feature in
                    HStack(alignment: .top, spacing: 16) {
                        Image(systemName: feature.icon)
                            .font(.system(size: 26))
                            .foregroundStyle(feature.iconColor)
                            .frame(width: 36, height: 36)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(LocalizedStringKey(feature.titleKey))
                                .font(.headline)

                            Text(LocalizedStringKey(feature.descriptionKey))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)

            Spacer(minLength: 12)

            // Continue Button
            Button {
                dismiss()
            } label: {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .keyboardShortcut(.defaultAction)
        }
        .padding(32)
        .frame(width: 480, height: 500)
    }
}
