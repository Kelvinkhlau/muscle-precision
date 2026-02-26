import SwiftUI

struct DashboardView: View {
    private let exercises = ExerciseRepository.all

    private var highRiskCount: Int {
        exercises.filter(\.highSkillRisk).count
    }

    private var beginnerCount: Int {
        exercises.filter(\.beginnerFriendly).count
    }

    private var subgroupCoverage: [(subgroup: MuscleSubgroup, count: Int)] {
        ExerciseRepository.subgroupCoverage()
            .map { ($0.key, $0.value) }
            .sorted { $0.subgroup.rawValue < $1.subgroup.rawValue }
    }

    private var groupCoverage: [(group: MuscleGroup, count: Int)] {
        ExerciseRepository.groupCoverage()
            .map { ($0.key, $0.value) }
            .sorted { $0.group.rawValue < $1.group.rawValue }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        statCard(title: "總動作", value: "\(exercises.count)", subtitle: "目標 92")
                        statCard(title: "⚠ 高技巧", value: "\(highRiskCount)", subtitle: "需 cue / 教練提示")
                        statCard(title: "✅ 新手友善", value: "\(beginnerCount)", subtitle: "可作 onboarding")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("L1 覆蓋")
                            .font(.headline)
                        ForEach(groupCoverage, id: \.group) { item in
                            HStack {
                                Label(item.group.title, systemImage: item.group.symbolName)
                                Spacer()
                                Text("\(item.count) 動作")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("L2 覆蓋檢查")
                            .font(.headline)
                        Text("設計書建議每個 L2 至少 3-5 個動作。本版每個 L2 固定 4 個。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        ForEach(subgroupCoverage, id: \.subgroup) { item in
                            HStack {
                                Text("\(item.subgroup.group.title) · \(item.subgroup.title)")
                                Spacer()
                                Text("\(item.count)")
                                    .font(.subheadline.monospacedDigit())
                            }
                            .padding(.vertical, 2)
                        }
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 8) {
                        Text("訓練模式基準")
                            .font(.headline)
                        Text("• 增肌：8-12 reps")
                        Text("• 力量：3-6 reps")
                        Text("• 平衡：6-10 reps")
                    }
                    .padding(14)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(16)
            }
            .navigationTitle("資料總覽")
        }
    }

    private func statCard(title: String, value: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.bold())
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
