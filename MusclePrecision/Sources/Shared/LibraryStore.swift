import Foundation

@MainActor
final class LibraryStore: ObservableObject {
    @Published var searchText: String = ""
    @Published var trainingMode: TrainingMode = .hypertrophy
    @Published var venueFilter: VenueFilter = .all
    @Published var selectedGroups: Set<MuscleGroup> = []
    @Published var selectedSubgroups: Set<MuscleSubgroup> = []
    @Published var onlyHighSkillRisk: Bool = false
    @Published var onlyBeginnerFriendly: Bool = false
    @Published var selectedExerciseKey: String?

    let allExercises: [Exercise] = ExerciseRepository.all.sorted { $0.key < $1.key }

    var filteredExercises: [Exercise] {
        allExercises.filter { exercise in
            if !selectedGroups.isEmpty, !selectedGroups.contains(exercise.group) {
                return false
            }
            if !selectedSubgroups.isEmpty, !selectedSubgroups.contains(exercise.subgroup) {
                return false
            }
            if onlyHighSkillRisk, !exercise.highSkillRisk {
                return false
            }
            if onlyBeginnerFriendly, !exercise.beginnerFriendly {
                return false
            }
            if !exercise.matches(venueFilter: venueFilter) {
                return false
            }
            return exercise.matches(query: searchText)
        }
    }

    var groupedExercises: [(group: MuscleGroup, exercises: [Exercise])] {
        let grouped = Dictionary(grouping: filteredExercises, by: { $0.group })
        return MuscleGroup.allCases.compactMap { group in
            guard let values = grouped[group], !values.isEmpty else { return nil }
            return (group, values.sorted { $0.key < $1.key })
        }
    }

    var selectedExercise: Exercise? {
        guard let selectedExerciseKey else { return filteredExercises.first }
        return filteredExercises.first(where: { $0.key == selectedExerciseKey })
            ?? allExercises.first(where: { $0.key == selectedExerciseKey })
    }

    func toggle(group: MuscleGroup) {
        if selectedGroups.contains(group) {
            selectedGroups.remove(group)
            selectedSubgroups = selectedSubgroups.filter { $0.group != group }
        } else {
            selectedGroups.insert(group)
        }
    }

    func toggle(subgroup: MuscleSubgroup) {
        if selectedSubgroups.contains(subgroup) {
            selectedSubgroups.remove(subgroup)
        } else {
            selectedSubgroups.insert(subgroup)
            selectedGroups.insert(subgroup.group)
        }
    }

    func clearFilters() {
        searchText = ""
        venueFilter = .all
        selectedGroups = []
        selectedSubgroups = []
        onlyHighSkillRisk = false
        onlyBeginnerFriendly = false
    }
}
