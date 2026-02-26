import SwiftUI

struct ExerciseDetailView: View {
    let exercise: Exercise
    let mode: TrainingMode

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                header
                repSection
                weightSection
                variantSection
                cueSection
            }
            .padding(20)
        }
        .navigationTitle(exercise.nameZH)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exercise.key)
                .font(.caption.monospaced())
                .foregroundStyle(.secondary)

            Text(exercise.fullName)
                .font(.title3.bold())

            HStack(spacing: 8) {
                StatusBadge(title: "\(exercise.group.title)-\(exercise.subgroup.title)", color: .accentColor)
                if exercise.highSkillRisk {
                    StatusBadge(title: "⚠ 高技巧", color: .orange)
                }
                if exercise.beginnerFriendly {
                    StatusBadge(title: "✅ 新手友善", color: .green)
                }
            }
        }
    }

    private var repSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("訓練模式 reps")
                .font(.headline)
            Text("增肌 8-12 / 力量 3-6 / 平衡 6-10")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("目前模式：\(mode.title)（\(mode.repLabel)）")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.accentColor)
        }
    }

    private var weightSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("肌肉權重（主/次/三）")
                .font(.headline)
            ForEach(exercise.weights) { contribution in
                WeightRow(contribution: contribution)
            }
        }
    }

    private var variantSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("器械 / 變體（G/H/H*）")
                .font(.headline)
            ForEach(exercise.variants) { variant in
                HStack {
                    Text(variant.name)
                    Spacer()
                    StatusBadge(title: variant.environment.rawValue, color: variant.environment == .gymOnly ? .purple : .blue)
                }
            }
        }
    }

    private var cueSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("教學提示與常見錯誤")
                .font(.headline)

            Text("Cues")
                .font(.subheadline.weight(.semibold))
            ForEach(exercise.cues, id: \.self) { cue in
                Text("• \(cue)")
                    .font(.subheadline)
            }

            Text("Common mistakes")
                .font(.subheadline.weight(.semibold))
                .padding(.top, 6)
            ForEach(exercise.commonMistakes, id: \.self) { issue in
                Text("• \(issue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
