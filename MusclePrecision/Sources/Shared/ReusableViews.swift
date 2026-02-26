import SwiftUI

struct FilterChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? Color.accentColor : Color(.secondarySystemBackground))
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
    }
}

struct StatusBadge: View {
    let title: String
    let color: Color

    var body: some View {
        Text(title)
            .font(.caption.weight(.bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .foregroundStyle(color)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }
}

struct WeightRow: View {
    let contribution: MuscleContribution

    var body: some View {
        HStack(spacing: 10) {
            Text(contribution.label)
                .font(.subheadline)
                .frame(width: 88, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .frame(width: proxy.size.width * CGFloat(contribution.percentage) / 100)
                }
            }
            .frame(height: 8)

            Text("\(contribution.percentage)%")
                .font(.caption.monospacedDigit())
                .frame(width: 40, alignment: .trailing)
        }
        .frame(height: 20)
    }
}
