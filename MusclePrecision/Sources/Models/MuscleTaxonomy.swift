import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable, Codable {
    case chest
    case back
    case shoulders
    case arms
    case legs
    case core

    var id: String { rawValue }

    var title: String {
        switch self {
        case .chest: "胸"
        case .back: "背"
        case .shoulders: "肩"
        case .arms: "手臂"
        case .legs: "腿"
        case .core: "核心"
        }
    }

    var englishTitle: String {
        switch self {
        case .chest: "Chest"
        case .back: "Back"
        case .shoulders: "Shoulders"
        case .arms: "Arms"
        case .legs: "Legs"
        case .core: "Core"
        }
    }

    var symbolName: String {
        switch self {
        case .chest: "figure.strengthtraining.traditional"
        case .back: "figure.run"
        case .shoulders: "figure.core.training"
        case .arms: "figure.arms.open"
        case .legs: "figure.walk"
        case .core: "figure.cooldown"
        }
    }
}

enum MuscleSubgroup: String, CaseIterable, Identifiable, Codable {
    case chestUpper
    case chestMiddle
    case chestLower

    case backLats
    case backMiddle
    case backLower
    case backTraps

    case shouldersFront
    case shouldersMiddle
    case shouldersRear

    case armsBicepsLong
    case armsBicepsShort
    case armsTricepsLong
    case armsTricepsLateral
    case armsTricepsMedial

    case legsQuads
    case legsHamstrings
    case legsGlutes
    case legsCalves

    case coreUpperAbs
    case coreLowerAbs
    case coreObliques
    case coreDeep

    var id: String { rawValue }

    var group: MuscleGroup {
        switch self {
        case .chestUpper, .chestMiddle, .chestLower:
            return .chest
        case .backLats, .backMiddle, .backLower, .backTraps:
            return .back
        case .shouldersFront, .shouldersMiddle, .shouldersRear:
            return .shoulders
        case .armsBicepsLong, .armsBicepsShort, .armsTricepsLong, .armsTricepsLateral, .armsTricepsMedial:
            return .arms
        case .legsQuads, .legsHamstrings, .legsGlutes, .legsCalves:
            return .legs
        case .coreUpperAbs, .coreLowerAbs, .coreObliques, .coreDeep:
            return .core
        }
    }

    var title: String {
        switch self {
        case .chestUpper: "上胸"
        case .chestMiddle: "中胸"
        case .chestLower: "下胸"
        case .backLats: "闊背"
        case .backMiddle: "中背"
        case .backLower: "下背"
        case .backTraps: "斜方"
        case .shouldersFront: "前三角"
        case .shouldersMiddle: "中三角"
        case .shouldersRear: "後三角"
        case .armsBicepsLong: "二頭長頭"
        case .armsBicepsShort: "二頭短頭"
        case .armsTricepsLong: "三頭長頭"
        case .armsTricepsLateral: "三頭外側"
        case .armsTricepsMedial: "三頭內側"
        case .legsQuads: "股四頭"
        case .legsHamstrings: "腿後"
        case .legsGlutes: "臀"
        case .legsCalves: "小腿"
        case .coreUpperAbs: "上腹"
        case .coreLowerAbs: "下腹"
        case .coreObliques: "腹斜"
        case .coreDeep: "深層核心"
        }
    }
}
