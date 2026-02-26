import SwiftUI

struct LibraryRootView: View {
    @EnvironmentObject private var store: LibraryStore

    var body: some View {
        NavigationSplitView {
            LibraryFilterPanel()
        } content: {
            LibraryExerciseList()
        } detail: {
            ContentUnavailableView("選擇動作", systemImage: "dumbbell", description: Text("從清單開啟任一動作查看完整資料"))
        }
        .navigationSplitViewStyle(.balanced)
    }
}

private struct LibraryFilterPanel: View {
    @EnvironmentObject private var store: LibraryStore

    private let subgroupColumns: [GridItem] = [
        GridItem(.adaptive(minimum: 110), spacing: 8)
    ]

    private var visibleSubgroups: [MuscleSubgroup] {
        if store.selectedGroups.isEmpty {
            return MuscleSubgroup.allCases
        }
        return MuscleSubgroup.allCases.filter { store.selectedGroups.contains($0.group) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("資料庫")
                    .font(.title2.bold())
                Text("\(ExerciseRepository.all.count) 個動作")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("訓練模式")
                        .font(.headline)
                    Picker("訓練模式", selection: $store.trainingMode) {
                        ForEach(TrainingMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text(store.trainingMode.repLabel)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("場地")
                        .font(.headline)
                    Picker("場地", selection: $store.venueFilter) {
                        ForEach(VenueFilter.allCases) { venue in
                            Text(venue.title).tag(venue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("L1 大肌群")
                        .font(.headline)
                    LazyVGrid(columns: subgroupColumns, alignment: .leading, spacing: 8) {
                        ForEach(MuscleGroup.allCases) { group in
                            Button {
                                store.toggle(group: group)
                            } label: {
                                FilterChip(title: group.title, isSelected: store.selectedGroups.contains(group))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("L2 細分區")
                        .font(.headline)
                    LazyVGrid(columns: subgroupColumns, alignment: .leading, spacing: 8) {
                        ForEach(visibleSubgroups) { subgroup in
                            Button {
                                store.toggle(subgroup: subgroup)
                            } label: {
                                FilterChip(title: subgroup.title, isSelected: store.selectedSubgroups.contains(subgroup))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                Toggle("只看 ⚠ 高技巧風險", isOn: $store.onlyHighSkillRisk)
                Toggle("只看 ✅ 新手友善", isOn: $store.onlyBeginnerFriendly)

                Button("清除篩選") {
                    store.clearFilters()
                }
                .buttonStyle(.bordered)
            }
            .padding(16)
        }
        .navigationTitle("動作庫")
    }
}

private struct LibraryExerciseList: View {
    @EnvironmentObject private var store: LibraryStore

    var body: some View {
        List {
            ForEach(store.groupedExercises, id: \.group) { section in
                Section {
                    ForEach(section.exercises) { exercise in
                        NavigationLink {
                            ExerciseDetailView(exercise: exercise, mode: store.trainingMode)
                        } label: {
                            ExerciseRowView(exercise: exercise)
                        }
                    }
                } header: {
                    Label("\(section.group.title) · \(section.group.englishTitle)", systemImage: section.group.symbolName)
                }
            }
        }
        .searchable(text: $store.searchText, prompt: "搜尋名稱 / Key / 變體")
        .navigationTitle("清單")
    }
}
