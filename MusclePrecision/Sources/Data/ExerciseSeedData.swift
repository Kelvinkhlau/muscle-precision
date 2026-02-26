import Foundation

enum ExerciseRepository {
    static let all: [Exercise] = {
        if let loaded = ExerciseJSONLoader.loadExercises(), !loaded.isEmpty {
            return loaded
        }

        let values = seeds.compactMap { seed -> Exercise? in
            guard let profile = profiles[seed.subgroup] else {
                return nil
            }

            return Exercise(
                key: seed.key,
                nameZH: seed.nameZH,
                nameEN: seed.nameEN,
                group: seed.subgroup.group,
                subgroup: seed.subgroup,
                variants: seed.variantsOverride ?? profile.defaultVariants,
                weights: profile.weights,
                highSkillRisk: seed.highSkillRisk,
                beginnerFriendly: seed.beginnerFriendly,
                cues: seed.cuesOverride ?? profile.defaultCues,
                commonMistakes: seed.mistakesOverride ?? profile.defaultMistakes
            )
        }

        precondition(values.count == 92, "Exercise seed count mismatch: \(values.count)")
        return values
    }()

    static func subgroupCoverage() -> [MuscleSubgroup: Int] {
        Dictionary(grouping: all, by: { $0.subgroup }).mapValues(\.count)
    }

    static func groupCoverage() -> [MuscleGroup: Int] {
        Dictionary(grouping: all, by: { $0.group }).mapValues(\.count)
    }

    static func randomPlan(
        mode: TrainingMode,
        venueFilter: VenueFilter,
        preferredGroups: Set<MuscleGroup>,
        count: Int,
        seed: UInt64 = UInt64(Date().timeIntervalSince1970)
    ) -> [ExercisePlanItem] {
        let requestedGroups = preferredGroups.isEmpty ? Set(MuscleGroup.allCases) : preferredGroups
        let filtered = all.filter {
            requestedGroups.contains($0.group) && $0.matches(venueFilter: venueFilter)
        }

        guard !filtered.isEmpty else { return [] }

        var generator = SeededGenerator(seed: seed)
        let grouped = Dictionary(grouping: filtered, by: { $0.group })
        var plan: [Exercise] = []

        for group in requestedGroups.sorted(by: { $0.rawValue < $1.rawValue }) {
            guard let choices = grouped[group], let picked = choices.randomElement(using: &generator) else {
                continue
            }
            plan.append(picked)
            if plan.count == count {
                break
            }
        }

        if plan.count < count {
            let remaining = filtered.shuffled(using: &generator).filter { candidate in
                !plan.contains(where: { $0.key == candidate.key })
            }
            for exercise in remaining {
                plan.append(exercise)
                if plan.count == count {
                    break
                }
            }
        }

        return plan.prefix(count).map {
            ExercisePlanItem(
                exercise: $0,
                sets: mode == .strength ? 4 : 3,
                repLabel: mode.repLabel
            )
        }
    }

    private static let profiles: [MuscleSubgroup: SubgroupProfile] = [
        .chestUpper: SubgroupProfile(
            weights: [
                MuscleContribution(label: "上胸", percentage: 70),
                MuscleContribution(label: "前三角", percentage: 20),
                MuscleContribution(label: "三頭", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "Smith", environment: .gymOnly),
                .init(name: "上斜胸推機", environment: .gymOnly),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["肩胛後收下沉", "核心收緊，避免腰椎代償", "推到頂端仍維持控制"],
            defaultMistakes: ["手肘過度外張", "借力彈震，失去張力"]
        ),
        .chestMiddle: SubgroupProfile(
            weights: [
                MuscleContribution(label: "中胸", percentage: 60),
                MuscleContribution(label: "前三角", percentage: 25),
                MuscleContribution(label: "三頭", percentage: 15)
            ],
            defaultVariants: [
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "胸推機", environment: .gymOnly),
                .init(name: "Smith", environment: .gymOnly),
                .init(name: "掌上壓", environment: .homePossible)
            ],
            defaultCues: ["落槓位置對齊中胸", "全程肩胛穩定", "離心放慢，向心爆發"],
            defaultMistakes: ["手腕後折", "屁股離凳造成下背壓力"]
        ),
        .chestLower: SubgroupProfile(
            weights: [
                MuscleContribution(label: "下胸", percentage: 70),
                MuscleContribution(label: "三頭", percentage: 20),
                MuscleContribution(label: "前三角", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "雙槓", environment: .gymOnly),
                .init(name: "下斜槓鈴", environment: .gymOnly),
                .init(name: "下斜啞鈴", environment: .homeWithRack),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "下斜胸推機", environment: .gymOnly)
            ],
            defaultCues: ["軀幹略前傾以吃到下胸", "肩胛保持穩定", "維持可控活動範圍"],
            defaultMistakes: ["肩膀聳起", "下放過深造成前肩不適"]
        ),
        .backLats: SubgroupProfile(
            weights: [
                MuscleContribution(label: "闊背", percentage: 70),
                MuscleContribution(label: "二頭長頭", percentage: 20),
                MuscleContribution(label: "中背", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "下拉機", environment: .gymOnly),
                .init(name: "高位纜繩", environment: .gymOnly),
                .init(name: "引體向上槓", environment: .homePossible),
                .init(name: "彈力帶下拉", environment: .homePossible)
            ],
            defaultCues: ["先沉肩再拉", "手肘向髖部方向帶", "胸口打開避免圓肩"],
            defaultMistakes: ["用手臂硬拉", "下背過度拱起"]
        ),
        .backMiddle: SubgroupProfile(
            weights: [
                MuscleContribution(label: "中背", percentage: 70),
                MuscleContribution(label: "闊背", percentage: 20),
                MuscleContribution(label: "二頭短頭", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "坐姿划船機", environment: .gymOnly),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["肩胛先收後拉", "脊柱中立", "頂峰停頓 1 秒"],
            defaultMistakes: ["身體大幅後仰甩動", "聳肩代償"]
        ),
        .backLower: SubgroupProfile(
            weights: [
                MuscleContribution(label: "下背", percentage: 60),
                MuscleContribution(label: "臀", percentage: 25),
                MuscleContribution(label: "腿後", percentage: 15)
            ],
            defaultVariants: [
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "陷阱槓", environment: .gymOnly),
                .init(name: "45° 背伸機", environment: .gymOnly),
                .init(name: "啞鈴", environment: .homePossible)
            ],
            defaultCues: ["維持髖 hinge", "核心 brace，背部中立", "腳掌穩定發力"],
            defaultMistakes: ["圓背拉起", "起拉時先抬臀"]
        ),
        .backTraps: SubgroupProfile(
            weights: [
                MuscleContribution(label: "斜方", percentage: 70),
                MuscleContribution(label: "後三角", percentage: 20),
                MuscleContribution(label: "深層核心", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "壺鈴", environment: .homePossible),
                .init(name: "Smith", environment: .gymOnly)
            ],
            defaultCues: ["頸部放鬆，肩膀向上後收", "頂峰停頓", "下放全程控制"],
            defaultMistakes: ["聳肩時頭前伸", "借力彈震"]
        ),
        .shouldersFront: SubgroupProfile(
            weights: [
                MuscleContribution(label: "前三角", percentage: 70),
                MuscleContribution(label: "上胸", percentage: 20),
                MuscleContribution(label: "三頭", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "Smith", environment: .gymOnly),
                .init(name: "機械肩推", environment: .gymOnly)
            ],
            defaultCues: ["肋骨下收，避免腰椎代償", "手肘與手腕垂直", "動作節奏穩定"],
            defaultMistakes: ["過度後仰推舉", "聳肩搶力"]
        ),
        .shouldersMiddle: SubgroupProfile(
            weights: [
                MuscleContribution(label: "中三角", percentage: 70),
                MuscleContribution(label: "斜方", percentage: 20),
                MuscleContribution(label: "前三角", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "機械側平舉", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["抬到肩高即可", "手肘略彎固定", "避免借力甩動"],
            defaultMistakes: ["聳肩過多", "用慣性甩起"]
        ),
        .shouldersRear: SubgroupProfile(
            weights: [
                MuscleContribution(label: "後三角", percentage: 70),
                MuscleContribution(label: "中背", percentage: 20),
                MuscleContribution(label: "斜方", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "反向蝴蝶機", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["胸口打開，肩胛穩定", "手肘帶動向外展", "專注後三角收縮"],
            defaultMistakes: ["聳肩代償", "重量過重造成擺盪"]
        ),
        .armsBicepsLong: SubgroupProfile(
            weights: [
                MuscleContribution(label: "二頭長頭", percentage: 70),
                MuscleContribution(label: "前臂", percentage: 20),
                MuscleContribution(label: "二頭短頭", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "槓鈴", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["手肘固定於身側", "上舉時旋後", "離心控制 2-3 秒"],
            defaultMistakes: ["身體後仰借力", "手肘前移過多"]
        ),
        .armsBicepsShort: SubgroupProfile(
            weights: [
                MuscleContribution(label: "二頭短頭", percentage: 70),
                MuscleContribution(label: "前臂", percentage: 20),
                MuscleContribution(label: "二頭長頭", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "牧師椅", environment: .gymOnly),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["手肘穩定不漂移", "全程維持張力", "頂峰停頓感受擠壓"],
            defaultMistakes: ["放下速度過快", "前臂主導過多"]
        ),
        .armsTricepsLong: SubgroupProfile(
            weights: [
                MuscleContribution(label: "三頭長頭", percentage: 70),
                MuscleContribution(label: "三頭外側", percentage: 20),
                MuscleContribution(label: "三頭內側", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "EZ 槓", environment: .homePossible),
                .init(name: "槓鈴", environment: .homePossible)
            ],
            defaultCues: ["手肘朝前固定", "完全伸肘但不鎖死", "避免肩膀代償"],
            defaultMistakes: ["手肘外開", "肩關節過度前傾"]
        ),
        .armsTricepsLateral: SubgroupProfile(
            weights: [
                MuscleContribution(label: "三頭外側", percentage: 70),
                MuscleContribution(label: "三頭長頭", percentage: 20),
                MuscleContribution(label: "三頭內側", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "雙槓", environment: .gymOnly),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "窄握槓鈴", environment: .homeWithRack)
            ],
            defaultCues: ["手肘靠近軀幹", "向下推到底", "向心發力避免甩動"],
            defaultMistakes: ["身體晃動借力", "手腕彎曲過度"]
        ),
        .armsTricepsMedial: SubgroupProfile(
            weights: [
                MuscleContribution(label: "三頭內側", percentage: 70),
                MuscleContribution(label: "三頭外側", percentage: 20),
                MuscleContribution(label: "三頭長頭", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "自重", environment: .homePossible),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["手肘固定，前臂轉動自然", "動作末端完整伸展", "控制回程"],
            defaultMistakes: ["肩膀前頂", "上臂移動過大"]
        ),
        .legsQuads: SubgroupProfile(
            weights: [
                MuscleContribution(label: "股四頭", percentage: 50),
                MuscleContribution(label: "臀", percentage: 30),
                MuscleContribution(label: "腿後", percentage: 20)
            ],
            defaultVariants: [
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "Smith", environment: .gymOnly),
                .init(name: "腿推機", environment: .gymOnly),
                .init(name: "腿伸展機", environment: .gymOnly)
            ],
            defaultCues: ["膝蓋方向對齊腳尖", "核心 brace，背部中立", "下蹲控制深度"],
            defaultMistakes: ["膝內夾", "重心過度前移"]
        ),
        .legsHamstrings: SubgroupProfile(
            weights: [
                MuscleContribution(label: "腿後", percentage: 70),
                MuscleContribution(label: "臀", percentage: 20),
                MuscleContribution(label: "下背", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "腿彎舉機", environment: .gymOnly),
                .init(name: "GHR", environment: .gymOnly)
            ],
            defaultCues: ["髖折疊主導", "腿後拉長感明確", "保持脊柱中立"],
            defaultMistakes: ["下放圓背", "膝蓋過度伸直鎖死"]
        ),
        .legsGlutes: SubgroupProfile(
            weights: [
                MuscleContribution(label: "臀", percentage: 70),
                MuscleContribution(label: "腿後", percentage: 20),
                MuscleContribution(label: "股四頭", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "槓鈴", environment: .homeWithRack),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["頂峰夾臀 1 秒", "肋骨下收避免腰代償", "腳跟穩定發力"],
            defaultMistakes: ["用下背頂起", "膝蓋位置漂移"]
        ),
        .legsCalves: SubgroupProfile(
            weights: [
                MuscleContribution(label: "小腿", percentage: 80),
                MuscleContribution(label: "股四頭", percentage: 10),
                MuscleContribution(label: "腿後", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "站姿提踵機", environment: .gymOnly),
                .init(name: "坐姿提踵機", environment: .gymOnly),
                .init(name: "啞鈴", environment: .homePossible),
                .init(name: "自重", environment: .homePossible)
            ],
            defaultCues: ["底部完整拉伸", "頂峰停頓", "控制離心避免彈震"],
            defaultMistakes: ["只做半程", "依靠慣性反彈"]
        ),
        .coreUpperAbs: SubgroupProfile(
            weights: [
                MuscleContribution(label: "上腹", percentage: 70),
                MuscleContribution(label: "下腹", percentage: 20),
                MuscleContribution(label: "深層核心", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "自重", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "機械", environment: .gymOnly)
            ],
            defaultCues: ["吐氣收腹發力", "脊柱逐節捲起", "保持骨盆穩定"],
            defaultMistakes: ["拉頸借力", "速度過快失去控制"]
        ),
        .coreLowerAbs: SubgroupProfile(
            weights: [
                MuscleContribution(label: "下腹", percentage: 70),
                MuscleContribution(label: "上腹", percentage: 20),
                MuscleContribution(label: "髖屈肌", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "自重", environment: .homePossible),
                .init(name: "懸垂架", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible)
            ],
            defaultCues: ["骨盆後傾先啟動", "避免擺盪", "離心慢放"],
            defaultMistakes: ["用髖屈肌甩腿", "下背拱起"]
        ),
        .coreObliques: SubgroupProfile(
            weights: [
                MuscleContribution(label: "腹斜", percentage: 70),
                MuscleContribution(label: "深層核心", percentage: 20),
                MuscleContribution(label: "上腹", percentage: 10)
            ],
            defaultVariants: [
                .init(name: "自重", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "壺鈴", environment: .homePossible)
            ],
            defaultCues: ["先穩定骨盆再旋轉", "軀幹長軸延伸", "控制節奏"],
            defaultMistakes: ["腰椎過度旋轉", "慣性甩動"]
        ),
        .coreDeep: SubgroupProfile(
            weights: [
                MuscleContribution(label: "深層核心", percentage: 60),
                MuscleContribution(label: "上腹", percentage: 20),
                MuscleContribution(label: "臀", percentage: 20)
            ],
            defaultVariants: [
                .init(name: "自重", environment: .homePossible),
                .init(name: "纜繩", environment: .gymOnly),
                .init(name: "彈力帶", environment: .homePossible),
                .init(name: "TRX", environment: .gymOnly)
            ],
            defaultCues: ["先 brace 再動作", "呼吸與收核心同步", "骨盆中立"],
            defaultMistakes: ["下背塌陷", "呼吸憋住過久"]
        )
    ]

    private static let seeds: [SeedItem] = [
        // Chest
        .init(key: "CH_U01", nameZH: "上斜臥推（啞鈴）", nameEN: "Incline DB Press", subgroup: .chestUpper, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "CH_U02", nameZH: "上斜臥推（槓鈴）", nameEN: "Incline Barbell Bench Press", subgroup: .chestUpper, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "CH_U03", nameZH: "低到高飛鳥（纜繩）", nameEN: "Low-to-High Cable Fly", subgroup: .chestUpper, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CH_U04", nameZH: "上斜胸推機", nameEN: "Incline Chest Press Machine", subgroup: .chestUpper, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "CH_M01", nameZH: "平板臥推（槓鈴）", nameEN: "Barbell Bench Press", subgroup: .chestMiddle, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "CH_M02", nameZH: "平板臥推（啞鈴）", nameEN: "DB Bench Press", subgroup: .chestMiddle, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CH_M03", nameZH: "坐姿胸推（機械）", nameEN: "Seated Chest Press Machine", subgroup: .chestMiddle, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CH_M04", nameZH: "蝴蝶機夾胸", nameEN: "Pec Deck Fly", subgroup: .chestMiddle, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "CH_L01", nameZH: "雙槓下壓（胸）", nameEN: "Chest Dips", subgroup: .chestLower, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "CH_L02", nameZH: "下斜臥推", nameEN: "Decline Press", subgroup: .chestLower, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "CH_L03", nameZH: "高到低飛鳥（纜繩）", nameEN: "High-to-Low Cable Fly", subgroup: .chestLower, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CH_L04", nameZH: "下斜胸推機", nameEN: "Decline Chest Press Machine", subgroup: .chestLower, highSkillRisk: false, beginnerFriendly: true),

        // Back
        .init(key: "BK_LA01", nameZH: "坐姿闊握下拉", nameEN: "Seated Lat Pulldown", subgroup: .backLats, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_LA02", nameZH: "引體向上", nameEN: "Pull-up", subgroup: .backLats, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "BK_LA03", nameZH: "單手划船（闊背偏向）", nameEN: "One-arm Row (Lat Bias)", subgroup: .backLats, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_LA04", nameZH: "直臂下拉", nameEN: "Straight-arm Pulldown", subgroup: .backLats, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "BK_MB01", nameZH: "坐姿纜繩划船", nameEN: "Seated Cable Row", subgroup: .backMiddle, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_MB02", nameZH: "胸托划船（機械/凳）", nameEN: "Chest-supported Row", subgroup: .backMiddle, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_MB03", nameZH: "俯身槓鈴划船", nameEN: "Barbell Bent-over Row", subgroup: .backMiddle, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "BK_MB04", nameZH: "高位划船（纜繩）", nameEN: "Seated High Back Row", subgroup: .backMiddle, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "BK_LB01", nameZH: "硬拉（傳統）", nameEN: "Conventional Deadlift", subgroup: .backLower, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "BK_LB02", nameZH: "羅馬尼亞硬拉", nameEN: "Romanian Deadlift (RDL)", subgroup: .backLower, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "BK_LB03", nameZH: "背伸展（45°）", nameEN: "Back Extension", subgroup: .backLower, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_LB04", nameZH: "槓鈴早安", nameEN: "Good Morning", subgroup: .backLower, highSkillRisk: true, beginnerFriendly: false),

        .init(key: "BK_TR01", nameZH: "槓鈴聳肩", nameEN: "Barbell Shrug", subgroup: .backTraps, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_TR02", nameZH: "啞鈴聳肩", nameEN: "DB Shrug", subgroup: .backTraps, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_TR03", nameZH: "農夫行走", nameEN: "Farmer's Carry", subgroup: .backTraps, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "BK_TR04", nameZH: "架上半程硬拉", nameEN: "Rack Pull", subgroup: .backTraps, highSkillRisk: true, beginnerFriendly: false),

        // Shoulders
        .init(key: "SH_F01", nameZH: "槓鈴肩推", nameEN: "Barbell Overhead Press", subgroup: .shouldersFront, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "SH_F02", nameZH: "坐姿啞鈴肩推", nameEN: "Seated DB Shoulder Press", subgroup: .shouldersFront, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_F03", nameZH: "阿諾肩推", nameEN: "Arnold Press", subgroup: .shouldersFront, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_F04", nameZH: "啞鈴前平舉", nameEN: "DB Front Raise", subgroup: .shouldersFront, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "SH_M01", nameZH: "啞鈴側平舉", nameEN: "DB Lateral Raise", subgroup: .shouldersMiddle, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_M02", nameZH: "纜繩側平舉", nameEN: "Cable Lateral Raise", subgroup: .shouldersMiddle, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_M03", nameZH: "機械側平舉", nameEN: "Machine Lateral Raise", subgroup: .shouldersMiddle, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_M04", nameZH: "寬握直立划船", nameEN: "Upright Row", subgroup: .shouldersMiddle, highSkillRisk: true, beginnerFriendly: false),

        .init(key: "SH_R01", nameZH: "反向飛鳥（啞鈴）", nameEN: "DB Reverse Fly", subgroup: .shouldersRear, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_R02", nameZH: "面拉", nameEN: "Face Pull", subgroup: .shouldersRear, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_R03", nameZH: "俯身反向飛鳥（纜繩）", nameEN: "Bent-over Cable Reverse Fly", subgroup: .shouldersRear, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "SH_R04", nameZH: "反向蝴蝶機", nameEN: "Rear Delt Machine Fly", subgroup: .shouldersRear, highSkillRisk: false, beginnerFriendly: true),

        // Arms - Biceps
        .init(key: "AR_BL01", nameZH: "上斜啞鈴彎舉", nameEN: "Incline DB Curl", subgroup: .armsBicepsLong, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_BL02", nameZH: "站姿槓鈴彎舉", nameEN: "Barbell Curl", subgroup: .armsBicepsLong, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_BL03", nameZH: "Bayesian 纜繩彎舉", nameEN: "Bayesian Cable Curl", subgroup: .armsBicepsLong, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_BL04", nameZH: "錘式彎舉", nameEN: "Hammer Curl", subgroup: .armsBicepsLong, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "AR_BS01", nameZH: "牧師椅彎舉", nameEN: "Preacher Curl", subgroup: .armsBicepsShort, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_BS02", nameZH: "集中彎舉", nameEN: "Concentration Curl", subgroup: .armsBicepsShort, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_BS03", nameZH: "高位纜繩彎舉", nameEN: "High Cable Curl", subgroup: .armsBicepsShort, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_BS04", nameZH: "反手彎舉", nameEN: "Reverse Curl", subgroup: .armsBicepsShort, highSkillRisk: false, beginnerFriendly: true),

        // Arms - Triceps
        .init(key: "AR_TL01", nameZH: "過頭臂屈伸（啞鈴）", nameEN: "DB Overhead Triceps Extension", subgroup: .armsTricepsLong, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "AR_TL02", nameZH: "過頭臂屈伸（纜繩）", nameEN: "Cable Overhead Triceps Extension", subgroup: .armsTricepsLong, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_TL03", nameZH: "仰臥臂屈伸", nameEN: "Lying Triceps Extension (Skull Crusher)", subgroup: .armsTricepsLong, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "AR_TL04", nameZH: "法式推（坐姿）", nameEN: "Seated French Press", subgroup: .armsTricepsLong, highSkillRisk: true, beginnerFriendly: false),

        .init(key: "AR_TLA01", nameZH: "纜繩下壓", nameEN: "Cable Triceps Pushdown", subgroup: .armsTricepsLateral, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_TLA02", nameZH: "窄握臥推", nameEN: "Close-grip Bench Press", subgroup: .armsTricepsLateral, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "AR_TLA03", nameZH: "三頭雙槓下壓", nameEN: "Triceps Dips", subgroup: .armsTricepsLateral, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "AR_TLA04", nameZH: "三頭後踢", nameEN: "Triceps Kickback", subgroup: .armsTricepsLateral, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "AR_TM01", nameZH: "反手纜繩下壓", nameEN: "Reverse-grip Pushdown", subgroup: .armsTricepsMedial, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_TM02", nameZH: "鑽石掌上壓", nameEN: "Diamond Push-up", subgroup: .armsTricepsMedial, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "AR_TM03", nameZH: "單臂纜繩下壓（鎖死）", nameEN: "Single-arm Pushdown (Lockout)", subgroup: .armsTricepsMedial, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "AR_TM04", nameZH: "繩索下壓（全伸展）", nameEN: "Rope Pushdown (Full Extension)", subgroup: .armsTricepsMedial, highSkillRisk: false, beginnerFriendly: true),

        // Legs
        .init(key: "LG_Q01", nameZH: "槓鈴背蹲", nameEN: "Back Squat", subgroup: .legsQuads, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "LG_Q02", nameZH: "槓鈴前蹲", nameEN: "Front Squat", subgroup: .legsQuads, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "LG_Q03", nameZH: "腿推機", nameEN: "Leg Press", subgroup: .legsQuads, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "LG_Q04", nameZH: "腿伸展機", nameEN: "Leg Extension", subgroup: .legsQuads, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "LG_H01", nameZH: "羅馬尼亞硬拉", nameEN: "Romanian Deadlift", subgroup: .legsHamstrings, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "LG_H02", nameZH: "腿彎舉（機械）", nameEN: "Leg Curl (Machine)", subgroup: .legsHamstrings, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "LG_H03", nameZH: "Nordic 腿後彎舉", nameEN: "Nordic Ham Curl", subgroup: .legsHamstrings, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "LG_H04", nameZH: "GHR 臀腿伸展", nameEN: "Glute-Ham Raise", subgroup: .legsHamstrings, highSkillRisk: true, beginnerFriendly: false),

        .init(key: "LG_G01", nameZH: "槓鈴臀推", nameEN: "Barbell Hip Thrust", subgroup: .legsGlutes, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "LG_G02", nameZH: "臀橋", nameEN: "Glute Bridge", subgroup: .legsGlutes, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "LG_G03", nameZH: "保加利亞分腿蹲（臀偏向）", nameEN: "Bulgarian Split Squat (Glute Bias)", subgroup: .legsGlutes, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "LG_G04", nameZH: "纜繩後踢", nameEN: "Cable Glute Kickback", subgroup: .legsGlutes, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "LG_C01", nameZH: "站姿提踵", nameEN: "Standing Calf Raise", subgroup: .legsCalves, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "LG_C02", nameZH: "坐姿提踵", nameEN: "Seated Calf Raise", subgroup: .legsCalves, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "LG_C03", nameZH: "腿推提踵", nameEN: "Leg Press Calf Press", subgroup: .legsCalves, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "LG_C04", nameZH: "單腳提踵", nameEN: "Single-leg Calf Raise", subgroup: .legsCalves, highSkillRisk: false, beginnerFriendly: true),

        // Core
        .init(key: "CR_UA01", nameZH: "仰臥卷腹", nameEN: "Crunch", subgroup: .coreUpperAbs, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_UA02", nameZH: "跪姿纜繩卷腹", nameEN: "Kneeling Cable Crunch", subgroup: .coreUpperAbs, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_UA03", nameZH: "下斜仰臥起坐", nameEN: "Decline Sit-up", subgroup: .coreUpperAbs, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "CR_UA04", nameZH: "機械卷腹", nameEN: "Machine Crunch", subgroup: .coreUpperAbs, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "CR_LA01", nameZH: "懸垂抬腿", nameEN: "Hanging Leg Raise", subgroup: .coreLowerAbs, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "CR_LA02", nameZH: "懸垂屈膝抬腿", nameEN: "Hanging Knee Raise", subgroup: .coreLowerAbs, highSkillRisk: true, beginnerFriendly: true),
        .init(key: "CR_LA03", nameZH: "反向卷腹", nameEN: "Reverse Crunch", subgroup: .coreLowerAbs, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_LA04", nameZH: "仰臥抬腿", nameEN: "Lying Leg Raise", subgroup: .coreLowerAbs, highSkillRisk: true, beginnerFriendly: true),

        .init(key: "CR_OB01", nameZH: "側平板支撐", nameEN: "Side Plank", subgroup: .coreObliques, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_OB02", nameZH: "纜繩劈木", nameEN: "Cable Woodchop", subgroup: .coreObliques, highSkillRisk: true, beginnerFriendly: false),
        .init(key: "CR_OB03", nameZH: "俄羅斯轉體", nameEN: "Russian Twist", subgroup: .coreObliques, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_OB04", nameZH: "自行車卷腹", nameEN: "Bicycle Crunch", subgroup: .coreObliques, highSkillRisk: false, beginnerFriendly: true),

        .init(key: "CR_TC01", nameZH: "前平板支撐", nameEN: "Front Plank", subgroup: .coreDeep, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_TC02", nameZH: "抗旋轉推（Pallof Press）", nameEN: "Anti-rotation Press (Pallof)", subgroup: .coreDeep, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_TC03", nameZH: "Dead Bug", nameEN: "Dead Bug", subgroup: .coreDeep, highSkillRisk: false, beginnerFriendly: true),
        .init(key: "CR_TC04", nameZH: "Bird Dog", nameEN: "Bird Dog", subgroup: .coreDeep, highSkillRisk: false, beginnerFriendly: true)
    ]
}

struct ExercisePlanItem: Identifiable {
    let exercise: Exercise
    let sets: Int
    let repLabel: String

    var id: String { exercise.id }
}

private struct SubgroupProfile {
    let weights: [MuscleContribution]
    let defaultVariants: [ExerciseVariant]
    let defaultCues: [String]
    let defaultMistakes: [String]
}

private struct SeedItem {
    let key: String
    let nameZH: String
    let nameEN: String
    let subgroup: MuscleSubgroup
    let highSkillRisk: Bool
    let beginnerFriendly: Bool
    let variantsOverride: [ExerciseVariant]?
    let cuesOverride: [String]?
    let mistakesOverride: [String]?

    init(
        key: String,
        nameZH: String,
        nameEN: String,
        subgroup: MuscleSubgroup,
        highSkillRisk: Bool,
        beginnerFriendly: Bool,
        variantsOverride: [ExerciseVariant]? = nil,
        cuesOverride: [String]? = nil,
        mistakesOverride: [String]? = nil
    ) {
        self.key = key
        self.nameZH = nameZH
        self.nameEN = nameEN
        self.subgroup = subgroup
        self.highSkillRisk = highSkillRisk
        self.beginnerFriendly = beginnerFriendly
        self.variantsOverride = variantsOverride
        self.cuesOverride = cuesOverride
        self.mistakesOverride = mistakesOverride
    }
}

private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed == 0 ? 0x9E3779B97F4A7C15 : seed
    }

    mutating func next() -> UInt64 {
        state = state &+ 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
