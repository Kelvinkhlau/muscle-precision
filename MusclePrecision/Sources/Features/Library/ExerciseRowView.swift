import SwiftUI

struct ExerciseRowView: View {
    let exercise: Exercise

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text(exercise.key)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                Spacer()
                Text(exercise.subgroup.title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(exercise.nameZH)
                .font(.headline)
            Text(exercise.nameEN)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 8) {
                if exercise.highSkillRisk {
                    StatusBadge(title: "⚠ 高技巧", color: .orange)
                }
                if exercise.beginnerFriendly {
                    StatusBadge(title: "✅ 新手友善", color: .green)
                }
                if exercise.supportsHome {
                    StatusBadge(title: "Home", color: .blue)
                }
            }
        }
        .padding(.vertical, 4)
    }
}
