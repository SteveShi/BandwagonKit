import SwiftUI

public struct ResourceGaugeCardView: View {
    public let titleKey: LocalizedStringKey
    public let icon: String
    public let percentage: Double
    public let detailText: String
    public let accentColor: Color

    public init(
        titleKey: LocalizedStringKey,
        icon: String,
        percentage: Double,
        detailText: String,
        accentColor: Color = .blue
    ) {
        self.titleKey = titleKey
        self.icon = icon
        self.percentage = min(max(percentage, 0.0), 1.0)
        self.detailText = detailText
        self.accentColor = accentColor
    }

    public var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 14) {
                // Header row: Icon, Title, and Percentage
                HStack(alignment: .center) {
                    HStack(spacing: 8) {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(dynamicColor)
                            .frame(width: 24, height: 24)
                            .background(dynamicColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 6, style: .continuous))

                        Text(titleKey)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.primary)
                    }

                    Spacer()

                    Text(String(format: "%.1f%%", percentage * 100))
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(dynamicColor)
                        .contentTransition(.numericText())
                }

                // Progress Bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(height: 8)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [dynamicColor.opacity(0.8), dynamicColor],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(geo.size.width * percentage, 6), height: 8)
                            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: percentage)
                    }
                }
                .frame(height: 8)

                // Detail footer
                Text(detailText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    private var dynamicColor: Color {
        if percentage >= 0.90 {
            return .red
        } else if percentage >= 0.75 {
            return .orange
        } else {
            return accentColor
        }
    }
}
