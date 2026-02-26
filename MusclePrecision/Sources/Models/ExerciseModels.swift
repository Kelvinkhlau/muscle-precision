import Foundation

enum TrainingMode: String, CaseIterable, Identifiable {
    case hypertrophy
    case strength
    case balanced

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hypertrophy: "增肌"
        case .strength: "力量"
        case .balanced: "平衡"
        }
    }

    var repLabel: String {
        switch self {
        case .hypertrophy: "8-12 reps"
        case .strength: "3-6 reps"
        case .balanced: "6-10 reps"
        }
    }

    var lowerBound: Int {
        switch self {
        case .hypertrophy: 8
        case .strength: 3
        case .balanced: 6
        }
    }

    var upperBound: Int {
        switch self {
        case .hypertrophy: 12
        case .strength: 6
        case .balanced: 10
        }
    }
}

enum VariantEnvironment: String, CaseIterable, Codable {
    case gymOnly = "G"
    case homePossible = "H"
    case homeWithRack = "H*"

    var title: String {
        switch self {
        case .gymOnly: "Gym-only"
        case .homePossible: "Home-possible"
        case .homeWithRack: "Home-possible (rack)"
        }
    }
}

enum VenueFilter: String, CaseIterable, Identifiable {
    case all
    case gym
    case home

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all: "全部"
        case .gym: "Gym"
        case .home: "Home"
        }
    }
}

struct ExerciseVariant: Hashable, Codable, Identifiable {
    let name: String
    let environment: VariantEnvironment

    var id: String { "\(name)-\(environment.rawValue)" }

    var displayText: String {
        "\(name) (\(environment.rawValue))"
    }
}

struct MuscleContribution: Hashable, Codable, Identifiable {
    let label: String
    let percentage: Int

    var id: String { "\(label)-\(percentage)" }
}

struct Exercise: Hashable, Codable, Identifiable {
    let key: String
    let nameZH: String
    let nameEN: String
    let group: MuscleGroup
    let subgroup: MuscleSubgroup
    let variants: [ExerciseVariant]
    let weights: [MuscleContribution]
    let highSkillRisk: Bool
    let beginnerFriendly: Bool
    let cues: [String]
    let commonMistakes: [String]

    var id: String { key }

    var fullName: String {
        "\(nameZH) (\(nameEN))"
    }

    var repGuide: String {
        "8-12 / 3-6 / 6-10"
    }

    var supportsHome: Bool {
        variants.contains { $0.environment != .gymOnly }
    }

    var supportsGym: Bool {
        variants.contains { $0.environment != .homePossible }
    }

    func matches(venueFilter: VenueFilter) -> Bool {
        switch venueFilter {
        case .all:
            return true
        case .gym:
            return supportsGym
        case .home:
            return supportsHome
        }
    }

    func matches(query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let normalized = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { return true }

        let fields = [
            key,
            nameZH,
            nameEN,
            group.title,
            subgroup.title,
            cues.joined(separator: " "),
            commonMistakes.joined(separator: " "),
            variants.map(\.name).joined(separator: " ")
        ]

        return fields.joined(separator: " ").lowercased().contains(normalized)
    }
}
