import Foundation
import XCTest
@testable import MusclePrecision

final class ExerciseJSONValidationTests: XCTestCase {
    func testTotalCountIs92() throws {
        let payload = try loadPayload()

        XCTAssertEqual(payload.totalExercises, 92, "totalExercises should be 92")
        XCTAssertEqual(payload.exercises.count, 92, "Actual exercise array count should be 92")
    }

    func testEveryL2HasExactlyFourExercises() throws {
        let payload = try loadPayload()
        let counts = Dictionary(grouping: payload.exercises, by: { $0.l2 }).mapValues(\.count)

        XCTAssertEqual(counts.count, MuscleSubgroup.allCases.count, "L2 coverage count mismatch")

        for subgroup in MuscleSubgroup.allCases {
            XCTAssertEqual(
                counts[subgroup.rawValue],
                4,
                "Expected 4 exercises for \(subgroup.rawValue)"
            )
        }
    }

    func testRequiredFieldsAndEnumMappings() throws {
        let payload = try loadPayload()

        let allKeys = payload.exercises.map(\.key)
        XCTAssertEqual(Set(allKeys).count, allKeys.count, "Exercise key should be unique")

        for exercise in payload.exercises {
            XCTAssertFalse(exercise.key.trimmed.isEmpty, "key cannot be empty")
            XCTAssertFalse(exercise.nameZH.trimmed.isEmpty, "nameZH cannot be empty: \(exercise.key)")
            XCTAssertFalse(exercise.nameEN.trimmed.isEmpty, "nameEN cannot be empty: \(exercise.key)")
            XCTAssertFalse(exercise.l1.trimmed.isEmpty, "l1 cannot be empty: \(exercise.key)")
            XCTAssertFalse(exercise.l2.trimmed.isEmpty, "l2 cannot be empty: \(exercise.key)")

            let group = try XCTUnwrap(MuscleGroup(rawValue: exercise.l1), "Invalid l1 in \(exercise.key)")
            let subgroup = try XCTUnwrap(MuscleSubgroup(rawValue: exercise.l2), "Invalid l2 in \(exercise.key)")
            XCTAssertEqual(group, subgroup.group, "l1/l2 mapping mismatch in \(exercise.key)")

            XCTAssertFalse(exercise.variants.isEmpty, "variants cannot be empty: \(exercise.key)")
            XCTAssertFalse(exercise.muscleWeights.isEmpty, "muscleWeights cannot be empty: \(exercise.key)")
            XCTAssertFalse(exercise.cues.isEmpty, "cues cannot be empty: \(exercise.key)")
            XCTAssertFalse(exercise.commonMistakes.isEmpty, "commonMistakes cannot be empty: \(exercise.key)")

            for variant in exercise.variants {
                XCTAssertTrue(["G", "H", "H*"].contains(variant.environment), "Invalid environment in \(exercise.key)")
                XCTAssertFalse(variant.name.trimmed.isEmpty, "variant name cannot be empty: \(exercise.key)")
            }

            let totalWeight = exercise.muscleWeights.reduce(into: 0) { partial, item in
                partial += item.percentage
            }
            XCTAssertEqual(totalWeight, 100, "muscleWeights should sum to 100: \(exercise.key)")
        }
    }

    func testTrainingModesAreExpected() throws {
        let payload = try loadPayload()
        let modeDict = Dictionary(uniqueKeysWithValues: payload.trainingModes.map { ($0.id, $0) })

        XCTAssertEqual(Set(modeDict.keys), Set(["hypertrophy", "strength", "balanced"]))

        XCTAssertEqual(modeDict["hypertrophy"]?.reps, "8-12 reps")
        XCTAssertEqual(modeDict["hypertrophy"]?.lowerBound, 8)
        XCTAssertEqual(modeDict["hypertrophy"]?.upperBound, 12)

        XCTAssertEqual(modeDict["strength"]?.reps, "3-6 reps")
        XCTAssertEqual(modeDict["strength"]?.lowerBound, 3)
        XCTAssertEqual(modeDict["strength"]?.upperBound, 6)

        XCTAssertEqual(modeDict["balanced"]?.reps, "6-10 reps")
        XCTAssertEqual(modeDict["balanced"]?.lowerBound, 6)
        XCTAssertEqual(modeDict["balanced"]?.upperBound, 10)
    }

    private func loadPayload() throws -> ExerciseJSONPayloadForTests {
        let candidateURL = findJSONURL()
        let url = try XCTUnwrap(candidateURL, "Could not find exercises.v1.json in test/main/project path")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ExerciseJSONPayloadForTests.self, from: data)
    }

    private func findJSONURL() -> URL? {
        let bundles = [Bundle(for: ExerciseJSONValidationTests.self), Bundle.main]
        for bundle in bundles {
            if let url = bundle.url(forResource: "exercises.v1", withExtension: "json") {
                return url
            }
        }

        let sourceFileURL = URL(fileURLWithPath: #filePath)
        let projectRoot = sourceFileURL
            .deletingLastPathComponent() // Tests
            .deletingLastPathComponent() // MusclePrecision root
        let directPath = projectRoot.appendingPathComponent("Data/exercises.v1.json")
        if FileManager.default.fileExists(atPath: directPath.path) {
            return directPath
        }

        return nil
    }
}

private struct ExerciseJSONPayloadForTests: Decodable {
    let schemaVersion: String
    let generatedAt: String
    let totalExercises: Int
    let trainingModes: [ExerciseJSONModeForTests]
    let exercises: [ExerciseJSONExerciseForTests]
}

private struct ExerciseJSONModeForTests: Decodable {
    let id: String
    let title: String
    let reps: String
    let lowerBound: Int
    let upperBound: Int
}

private struct ExerciseJSONExerciseForTests: Decodable {
    let key: String
    let nameZH: String
    let nameEN: String
    let l1: String
    let l2: String
    let variants: [ExerciseJSONVariantForTests]
    let muscleWeights: [ExerciseJSONWeightForTests]
    let flags: ExerciseJSONFlagsForTests
    let cues: [String]
    let commonMistakes: [String]
}

private struct ExerciseJSONVariantForTests: Decodable {
    let name: String
    let environment: String
}

private struct ExerciseJSONWeightForTests: Decodable {
    let label: String
    let percentage: Int
}

private struct ExerciseJSONFlagsForTests: Decodable {
    let highSkillRisk: Bool
    let beginnerFriendly: Bool
}

private extension String {
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
