# 初期データ（Seed）ガイド

最終更新: 2025-09-10

この文書は、CardPro のデータベース初期データ（Seed）の目的、実行タイミング、生成内容、冪等性、検証・運用方法をまとめたものです。

## 実行タイミングと入口
- 初期化の入口: `lib/core/di/injection_container.dart` の `init()` 内で以下を順に呼び出します。
  - `ensureDefaultCardEffectsExist()`
  - `ensureInitialCardsAndDeckExist()`
  - `ensureInitialContainersExist()`

## 生成データ一覧
- カード効果（マスタ）
  - 関数: `ensureDefaultCardEffectsExist()`
  - 生成: 「Basic」「Energy Boost」「Damage Up」
  - 冪等性: `cardEffects` が空のときのみ投入

- カード/カード個体/デッキ
  - 関数: `ensureInitialCardsAndDeckExist()`
  - 生成: 代表的なカード10種と対応する個体、デッキ「Default Deck A」「Default Deck B」
  - 個体の割当: Aに8枚、Bに2枚＋Aから重複3枚（例）を `main` に配置
  - 冪等性: 既存マスタ未存在・個体未存在・デッキ未存在の場合に限り投入（それぞれ独立に判定）

- 汎用コンテナ（非デッキ）
  - 関数: `ensureInitialContainersExist()`
  - 生成: 非デッキのコンテナが0件であれば、名称「保管庫」を1件作成（`containerType = 'drawer'`）
  - 冪等性: 「非デッキのコンテナが1件以上存在する場合は挿入しない」

## 依存関係と順序
1. カード効果 → 2. カード/個体/デッキ → 3. 非デッキのコンテナ
- 効果IDを参照するため、1→2 の順は必須。
- 3 は独立ですが、初期化の可読性のため続けて呼び出しています。

## ログと確認
- 初期化完了ログ（例）: `DB seeded: cards=10, instances=10, containers=1`
- 簡易確認（SQL）:
  - 非デッキのコンテナ数: `SELECT COUNT(*) FROM containers WHERE containerType <> 'deck';`
  - デッキ数: `SELECT COUNT(*) FROM containers WHERE containerType = 'deck';`
  - 個体のデッキ割当: `SELECT COUNT(*) FROM container_card_locations;`

## 冪等性/再実行の考え方
- 各関数は「存在チェック→不足分のみ投入」を基本とし、複数回実行しても重複を生みません。
- 既存データに依存するため、DB を削除/初期化した場合は自動で再投入されます。

## 変更手順（新しいシードを追加する）
1. `lib/db/seed_data.dart` に新しい関数を追加（必ず冪等にする）
2. `lib/core/di/injection_container.dart` の `init()` に呼び出しを追加
3. この文書（seed_data.md）と `docs/db_basic_design.md` の Seed 節を更新
4. ログや検証手順を追記

## 既知の注意点
- `containerType` は UI/機能で意味を持つため、初期値（`deck`/`drawer` など）の綴りを変更する場合は参照箇所を合わせて更新してください。
- 画面上で追加される非デッキのコンテナは `containerType` が自由入力です（例: `drawer`, `binder`）。

## 参照
- 設計書（Seed 節）: `docs/db_basic_design.md`
- 実装: `lib/db/seed_data.dart`, `lib/core/di/injection_container.dart`
