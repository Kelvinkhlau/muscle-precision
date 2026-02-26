import Foundation

enum ExerciseJSONLoader {
    static func loadExercises(from bundle: Bundle = .main) -> [Exercise]? {
        guard let url = bundle.url(forResource: "exercises.v1", withExtension: "json") else {
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let payload = try JSONDecoder().decode(ExerciseJSONPayload.self, from: data)
            let mapped = payload.exercises.compactMap { item -> Exercise? in
                guard
                    let group = MuscleGroup(rawValue: item.l1),
                    let subgroup = MuscleSubgroup(rawValue: item.l2),
                    subgroup.group == group
                else {
                    return nil
                }

                let variants = item.variants.compactMap { variant -> ExerciseVariant? in
                    guard let env = VariantEnvironment(rawValue: variant.environment) else {
                        return nil
                    }
                    return ExerciseVariant(name: variant.name, environment: env)
                }

                let weights = item.muscleWeights.map {
                    MuscleContribution(label: $0.label, percentage: $0.percentage)
                }

                return Exercise(
                    key: item.key,
                    nameZH: item.nameZH,
                    nameEN: item.nameEN,
                    group: group,
                    subgroup: subgroup,
                    variants: variants,
                    weights: weights,
                    highSkillRisk: item.flags.highSkillRisk,
                    beginnerFriendly: item.flags.beginnerFriendly,
                    cues: item.cues,
                    commonMistakes: item.commonMistakes
                )
            }

            guard !mapped.isEmpty else {
                return nil
            }

            #if DEBUG
            if mapped.count != payload.totalExercises {
                print("[ExerciseJSONLoader] totalExercises mismatch: payload=\(payload.totalExercises), mapped=\(mapped.count)")
            }
            #endif

            return mapped.sorted { $0.key < $1.key }
        } catch {
            #if DEBUG
            print("[ExerciseJSONLoader] failed to load JSON: \(error)")
            #endif
            return nil
        }
    }
}

private struct ExerciseJSONPayload: Decodable {
    let schemaVersion: String
    let generatedAt: String
    let totalExercises: Int
    let trainingModes: [ExerciseJSONMode]
    let exercises: [ExerciseJSONExercise]
}

private struct ExerciseJSONMode: Decodable {
    let id: String
    let title: String
    let reps: String
    let lowerBound: Int
    let upperBound: Int
}

private struct ExerciseJSONExercise: Decodable {
    let key: String
    let nameZH: String
    let nameEN: String
    let l1: String
    let l2: String
    let flags: ExerciseJSONFlags
    let variants: [ExerciseJSONVariant]
    let muscleWeights: [ExerciseJSONWeight]
    let cues: [String]
    let commonMistakes: [String]
}

private struct ExerciseJSONFlags: Decodable {
    let highSkillRisk: Bool
    let beginnerFriendly: Bool
}

private struct ExerciseJSONVariant: Decodable {
    let name: String
    let environment: String
}

private struct ExerciseJSONWeight: Decodable {
    let label: String
    let percentage: Int
}
