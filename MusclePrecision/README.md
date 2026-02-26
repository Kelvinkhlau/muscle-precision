# Muscle Precision (iPhone + iPad)

基於《Muscle Precision App v1.0 開發者可用動作資料庫設計報告》建立的 SwiftUI Universal App。

## 已落地功能

- 92 個動作資料（L1/L2 全覆蓋，每個 L2 固定 4 個）
- L1 / L2 篩選、關鍵字搜尋、`G / H / H*` 場地標記
- `⚠ 高技巧風險` 與 `✅ 新手友善` 雙標記
- 三種訓練模式 reps：
  - 增肌 `8-12`
  - 力量 `3-6`
  - 平衡 `6-10`
- 快速排程（依模式/場地/肌群自動生成）
- 覆蓋率總覽（L1/L2 統計）
- iPhone / iPad 自適應（`NavigationSplitView` + `TabView`）
- App 啟動時優先載入 `Data/exercises.v1.json`（缺檔或格式錯誤時自動 fallback 到內建種子資料）

## 開啟方式

1. 開啟 `MusclePrecision/MusclePrecision.xcodeproj`
2. 若要實機執行，在 Xcode `Signing & Capabilities` 設定你的 Team
3. 選擇 iPhone 或 iPad Simulator 後直接 Run

## 我已驗證

- `xcodebuild -project "MusclePrecision/MusclePrecision.xcodeproj" -scheme "MusclePrecision" -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build`
- 編譯成功

## 匯出 92 筆 JSON

- 輸出檔案：`MusclePrecision/Data/exercises.v1.json`
- 匯出指令（在專案根目錄執行）：

```bash
swiftc \
  "MusclePrecision/Sources/Models/MuscleTaxonomy.swift" \
  "MusclePrecision/Sources/Models/ExerciseModels.swift" \
  "MusclePrecision/Sources/Data/ExerciseJSONLoader.swift" \
  "MusclePrecision/Sources/Data/ExerciseSeedData.swift" \
  "MusclePrecision/Scripts/export_exercises_json.swift" \
  -o /tmp/muscle_exporter

/tmp/muscle_exporter "MusclePrecision/Data/exercises.v1.json"
```

## JSON 驗證測試

- 測試內容：
  - 總數必須為 92
  - 每個 L2 必須剛好 4 個動作
  - 必要欄位不可為空、key 必須唯一
  - `l1/l2` 枚舉映射、`G/H/H*` 環境值、肌肉權重總和必須合法
  - 三個訓練模式（hypertrophy/strength/balanced）與 reps 區間一致
- 執行指令：

```bash
xcodebuild \
  -project "MusclePrecision/MusclePrecision.xcodeproj" \
  -scheme "MusclePrecision" \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.2' \
  CODE_SIGNING_ALLOWED=NO \
  test
```

## CI（GitHub Actions）

- Workflow 檔案：`.github/workflows/ios-ci.yml`
- 觸發時機：`push main`、`pull_request`、手動觸發
- 流程：
  1. 檢查 Xcode 版本
  2. 編譯並執行 JSON 匯出器（輸出到 `/tmp/exercises.v1.json`）
  3. 檢查匯出結果是否維持 `92` 筆
  4. 執行 `MusclePrecision/Scripts/ci_run_tests.sh`（自動選可用 iPhone simulator 後跑 `xcodebuild test`）
