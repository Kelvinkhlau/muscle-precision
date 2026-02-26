import Foundation

struct ExportPayload: Codable {
    let schemaVersion: String
    let generatedAt: String
    let totalExercises: Int
    let trainingModes: [ExportTrainingMode]
    let exercises: [ExportExercise]
}

struct ExportTrainingMode: Codable {
    let id: String
    let title: String
    let reps: String
    let lowerBound: Int
    let upperBound: Int
}

struct ExportExercise: Codable {
    let key: String
    let nameZH: String
    let nameEN: String
    let l1: String
    let l1Title: String
    let l2: String
    let l2Title: String
    let repGuide: String
    let flags: ExportFlags
    let variants: [ExportVariant]
    let muscleWeights: [ExportWeight]
    let cues: [String]
    let commonMistakes: [String]
}

struct ExportFlags: Codable {
    let highSkillRisk: Bool
    let beginnerFriendly: Bool
}

struct ExportVariant: Codable {
    let name: String
    let environment: String
    let environmentTitle: String
}

struct ExportWeight: Codable {
    let label: String
    let percentage: Int
}

@main
struct ExerciseJSONExporter {
    static func main() throws {
        let defaultOutput = "MusclePrecision/Data/exercises.v1.json"
        let outputPath = CommandLine.arguments.dropFirst().first ?? defaultOutput
        let url = URL(fileURLWithPath: outputPath)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let payload = ExportPayload(
            schemaVersion: "1.0",
            generatedAt: formatter.string(from: Date()),
            totalExercises: ExerciseRepository.all.count,
            trainingModes: TrainingMode.allCases.map {
                ExportTrainingMode(
                    id: $0.rawValue,
                    title: $0.title,
                    reps: $0.repLabel,
                    lowerBound: $0.lowerBound,
                    upperBound: $0.upperBound
                )
            },
            exercises: ExerciseRepository.all.sorted { $0.key < $1.key }.map { exercise in
                ExportExercise(
                    key: exercise.key,
                    nameZH: exercise.nameZH,
                    nameEN: exercise.nameEN,
                    l1: exercise.group.rawValue,
                    l1Title: exercise.group.title,
                    l2: exercise.subgroup.rawValue,
                    l2Title: exercise.subgroup.title,
                    repGuide: exercise.repGuide,
                    flags: ExportFlags(
                        highSkillRisk: exercise.highSkillRisk,
                        beginnerFriendly: exercise.beginnerFriendly
                    ),
                    variants: exercise.variants.map {
                        ExportVariant(
                            name: $0.name,
                            environment: $0.environment.rawValue,
                            environmentTitle: $0.environment.title
                        )
                    },
                    muscleWeights: exercise.weights.map {
                        ExportWeight(label: $0.label, percentage: $0.percentage)
                    },
                    cues: exercise.cues,
                    commonMistakes: exercise.commonMistakes
                )
            }
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]

        let data = try encoder.encode(payload)
        let directory = url.deletingLastPathComponent()
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        try data.write(to: url, options: .atomic)

        print("Exported \(payload.totalExercises) exercises to \(url.path)")
    }
}
