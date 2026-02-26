import SwiftUI

struct PlannerView: View {
    @EnvironmentObject private var store: LibraryStore

    @State private var selectedGroups: Set<MuscleGroup> = Set(MuscleGroup.allCases)
    @State private var itemCount: Int = 6
    @State private var plan: [ExercisePlanItem] = []

    private let columns: [GridItem] = [GridItem(.adaptive(minimum: 100), spacing: 8)]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("根據設計書的 reps 與 G/H 規則，自動組出今日訓練清單。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Picker("訓練模式", selection: $store.trainingMode) {
                        ForEach(TrainingMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Picker("場地", selection: $store.venueFilter) {
                        ForEach(VenueFilter.allCases) { venue in
                            Text(venue.title).tag(venue)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .leading, spacing: 10) {
                        Text("肌群偏好")
                            .font(.headline)
                        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
                            ForEach(MuscleGroup.allCases) { group in
                                Button {
                                    toggle(group)
                                } label: {
                                    FilterChip(title: group.title, isSelected: selectedGroups.contains(group))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Stepper("動作數量：\(itemCount)", value: $itemCount, in: 3...10)

                    Button("重新生成") {
                        generatePlan()
                    }
                    .buttonStyle(.borderedProminent)

                    Divider()

                    if plan.isEmpty {
                        ContentUnavailableView("尚未生成清單", systemImage: "calendar.badge.clock", description: Text("點擊「重新生成」後會自動挑選動作"))
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("今日清單")
                                .font(.headline)
                            ForEach(Array(plan.enumerated()), id: \.element.id) { index, item in
                                NavigationLink {
                                    ExerciseDetailView(exercise: item.exercise, mode: store.trainingMode)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(index + 1). \(item.exercise.nameZH)")
                                            .font(.headline)
                                            .foregroundStyle(.primary)
                                        Text("\(item.exercise.key) · \(item.sets) sets · \(item.repLabel)")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        HStack(spacing: 8) {
                                            if item.exercise.highSkillRisk {
                                                StatusBadge(title: "⚠", color: .orange)
                                            }
                                            if item.exercise.beginnerFriendly {
                                                StatusBadge(title: "✅", color: .green)
                                            }
                                            StatusBadge(title: item.exercise.group.title, color: .accentColor)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(16)
            }
            .navigationTitle("快速排程")
        }
        .onAppear {
            if plan.isEmpty {
                generatePlan()
            }
        }
    }

    private func toggle(_ group: MuscleGroup) {
        if selectedGroups.contains(group) {
            selectedGroups.remove(group)
        } else {
            selectedGroups.insert(group)
        }

        if selectedGroups.isEmpty {
            selectedGroups = Set(MuscleGroup.allCases)
        }
    }

    private func generatePlan() {
        plan = ExerciseRepository.randomPlan(
            mode: store.trainingMode,
            venueFilter: store.venueFilter,
            preferredGroups: selectedGroups,
            count: itemCount
        )
    }
}
