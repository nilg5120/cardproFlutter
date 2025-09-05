# 要件定義書 v2 - CardPro（カード＆デッキ管理アプリ）
アプリ名: CardPro - MTG Edition（仮）

最終更新日: 2025-09-05

---

## 1. 概要
オフライン前提の単一ユーザー向けカード＆デッキ管理アプリ。MTG（および将来的な類似TCG）を対象に、カード情報の記録、効果の共通管理、デッキ構築・運用補助を提供する。

---

## 2. 目的（ゴール）
- カードコレクションの電子管理（重複・所在の一元化）
- デッキ構築と運用の効率化（構成チェック、自動補完候補）
- UI からのカード CRUD／メモ管理の提供

---

## 3. スコープ / 非対象
### スコープ（本バージョン）
- ローカル保存（SQLite/Drift）
- カード管理（マスタ+インスタンス）
- デッキ（=Container）管理とカード配置（main/side）
- デッキ使用フロー：構成チェックと補完候補提示
- DI(GetIt)、Clean Architecture + BLoC

### 非対象（将来拡張）
- オンライン同期/共有（Firebase 等）
- 画像アップロード（カード/デッキ）
- 高度検索・絞り込み、OCR、自動スクレイピング
- 複数ユーザー/アカウント、コラボ

---

## 4. 利用対象者（ペルソナ）
- MTGプレイヤー：自作デッキの管理・試行を頻繁に行う
- コレクター：入手カードの所在とメモを残したい

---

## 5. 用語定義
- **カード（マスタ）**: 同一カード名/セット/番号で共通化された情報単位
- **カードインスタンス**: ユーザーが所有する物理（または仮想）コピー1枚を表すエンティティ（メモ付）
- **効果（CardEffect）**: 汎用の効果テキストを集約したマスタ
- **Container（デッキ）**: カードインスタンスの集合。`type` により deck/binder 等に拡張可能
- **Location**: Container 内の配置区分（`main`, `side` など）

---

## 6. 前提・制約
- OS: Android（Flutter/Material）（IOSは将来）
- DB: SQLite（Drift）
- アプリ: オフライン前提・単一ユーザー
- 言語: 日本語（英語は将来）
- ルール: 具体的な対戦レギュレーションは**設定可能なルール集合**として扱う（固定記述しない）

---

## 7. 成功指標（KPI）

---

## 8. ユースケース
1. カードを追加/編集/削除する
3. カードインスタンスにメモを残す
4. デッキを作成し、カードを main/side に配置する
5. デッキ使用フローで構成チェックし、不足を補完候補から選ぶ
6. カード一覧/デッキ一覧を閲覧・ソート（簡易検索は将来）

---

## 9. 機能要件（FR）

### 9.1 カード管理
- **FR-Card-001**: カード（マスタ）の追加/編集/削除ができる。
- **FR-Card-003**: カードインスタンス（所有コピー）を作成し、自由記述メモを保存できる。
- **FR-Card-004**: カード一覧で名称/セット/レアリティ/メモの要約を表示する。

**受け入れ基準（例）**  
Given カード追加フォーム  
When 必須項目（名称、セット）を入力して保存  
Then カードがマスタに作成され、一覧に反映される。

### 9.2 デッキ（Container）管理
- **FR-Deck-001**: デッキの作成/編集/削除ができる（`type=deck`）。
- **FR-Deck-002**: デッキにカードインスタンスを追加し、`location` を `main`/`side` から選べる。
- **FR-Deck-003**: デッキ詳細画面で `main`/`side` ごとの枚数とリストを表示する。
- **FR-Deck-004**: 1つのカードインスタンスは同時に複数 Container に属せない（整合性）。

**受け入れ基準（例）**  
Given デッキ詳細  
When `+` からカードインスタンスを選択し `main` を指定  
Then 当該インスタンスが重複なく `main` に追加される。

### 9.3 デッキ使用フロー（構成チェック＆補完）
- **FR-Use-001**: 「使用」ボタン押下で、現在のデッキ構成をルール集合で検証する。
- **FR-Use-002**: 不足条件がある場合、補完候補リストを提示する。
  - 候補ソース: 未所属インスタンス / 他デッキ所属インスタンス（区別表示）
- **FR-Use-003**: 候補から選択して即時に差し替え/追加できる（ユーザー確認あり）。
- **FR-Use-004**: ルール集合はアプリ内設定で切替可能（例: デッキ枚数=60 など）。

**受け入れ基準（例）**  
Given デッキ使用  
When 60枚未満  
Then 「不足: X枚」「候補: 未所属Y枚/他デッキZ枚」を表示する。

### 9.4 共通
- **FR-Common-001**: DI(GetIt) による依存解決。Repository 層を介した永続化。
- **FR-Common-002**: Clean Architecture + BLoC に基づく状態管理とテスト容易性。
- **FR-Common-003**: 簡易並び替え（名称/レアリティ/セット）。

---

## 10. 画面要件
- ホーム（Cards / Decks ナビ）
- カード一覧
- カード追加/編集ダイアログ
- カード詳細（読み/編集トグル）
- デッキ一覧
- デッキ詳細（main/sideタブ、枚数バッジ）
- デッキ追加/編集ダイアログ

**UIガイド**
- FAB/`+` で追加。保存/キャンセルはダイアログ下部に固定。
- リストは仮想スクロール、アイテム押下で詳細/編集。
- 「使用」ボタンはデッキ詳細の右上に配置。

---

## 11. データ要件（スキーマ概要）

### 11.1 テーブル
| テーブル | 主なカラム | 備考 |
|---|---|---|
| `cards` | `id PK`, `name`, `set_name`, `number`, `rarity`, `type`, `card_effect_id FK?`, `created_at` | `name+set_name+number` にユニーク制約推奨 |
| `card_effects` | `id PK`, `title`, `text`, `game`, `effect_hash UNIQUE`, `created_at` | 同一効果の重複排除に `effect_hash` |
| `card_instances` | `id PK`, `card_id FK`, `memo`, `acquired_at`, `tags_json` | 物理/仮想1枚につき1行 |
| `containers` | `id PK`, `name`, `description`, `type`(deck/binder), `game`, `thumbnail_uri`, `created_at` | デッキ以外にも拡張可 |
| `container_card_locations` | `id PK`, `container_id FK`, `card_instance_id FK UNIQUE`, `location`(main/side), `position` | 1インスタンス=1Container（UNIQUE制約） |
| `app_settings` | `id PK(=1)`, `ruleset_json`, `locale`, `theme` | ルール集合をJSONで保持 |

### 11.2 参照整合性
- `card_instances.card_id` は `pokemon_cards.id` に必須参照
- `container_card_locations.card_instance_id` は UNIQUE（多重所属防止）
- 参照削除時の動作: `ON DELETE RESTRICT`（安全優先）

---

## 12. ビジネスルール（例）
- R-001: デッキ枚数は `ruleset_json.deck_size` に一致する必要がある（例: 60）。
- R-002: 特定カードの最大投入枚数は `ruleset_json.max_copies` に従う（名称/番号単位）。
- R-003: `side` はルールセットで有効化された場合のみ使用可能。

---

## 13. 非機能要件（NFR）
- **性能**: 一覧スクロール60fps、検索（将来）100ms/クエリを目標
- **信頼性**: トランザクションで CRUD の整合性を担保。アプリ強制終了時も DB 一貫性維持
- **保守性**: UseCase/Repository 分離。BLoC 単体テスト可能
- **UX**: Undo（スナックバー）/Redo はMVPでは任意。エラーメッセージはユーザー文言
- **データ保護**: 端末ローカルのみ。端末外搬出はエクスポート（将来）で実施
- **移行**: Drift の schema versioning を使用。破壊的変更はマイグレーション必須

---

## 14. テスト要件
- **Unit**: UseCase/Repository 80%カバレッジ目標
- **Widget**: 主要フォーム/一覧のレンダリングとバリデーション
- **E2E**: 初回起動→カード登録→デッキ作成→使用フローまでのハッピーパス
- **テストデータ**: サンプルカード 30枚、重複インスタンス 10枚、ルールセット2種

---

## 15. ログ/診断
- 重要操作（作成/削除/使用フロー結果）をローカルログへ（循環上限）
- クラッシュレポートは非対応（将来: Firebase Crashlytics）

---

## 16. リリース計画
- **MVP (v0.1)**: カード/効果/インスタンス、デッキ、使用フロー（不足表示のみ）
- **v0.2**: 補完候補からの即時差し替え、簡易並び替え、設定ルール編集
- **v0.3**: 画像サムネ（デッキ）、インポート/エクスポート（JSON）
- **Backlog**: 高度検索・フィルタ、Firebase同期、共有、OCR

---

## 17. リスクと対策
- 効果の重複増殖 → `effect_hash` によるユニーク化/マージUI
- 多重所属バグ → DB UNIQUE とアプリ層バリデーションの二重防御
- ルール差異（ゲーム別） → `ruleset_json` をゲームごとに切替可能に

---

## 18. 変更履歴
- v2（本書）: デッキ使用フローの要件明確化、データ整合性/UNIQUE制約、ルール集合・KPIを追加
- v1: 初版（概要/機能一覧/画面一覧/非機能要件 を定義）

---

## 19. MTG拡張仕様（v3 追補）

### 19.1 目的 / スコープ
- 本アプリを **Magic: The Gathering（MTG）** 向けに最適化する。
- 既存アーキテクチャ（SQLite/Drift、Clean+Bloc、DI）は維持。`game="MTG"` を前提とする。
- ルールや禁止・制限は固定せず、**ルール集合（ruleset_json）** で切替・更新可能とする（将来の更新に耐える）。

### 19.2 データ要件（MTG特有フィールド）
> 既存の `cards` は一般化し、カードマスタを `cards` として運用（または `mtg_cards` 新設）。下記は **追加/変更カラム** の提案。

- **cards**（MTG用主要カラム）
  - `id PK`
  - `game` ("MTG")
  - `name`（多面/MDFC は面ごとに `card_faces` に格納）
  - `set_name`, `set_code`, `collector_number`
  - `rarity`（common/uncommon/rare/mythic など）
  - `oracle_text`
  - `mana_cost`（例: "{1}{U}{U}"） / `mana_value`（=旧CMC）
  - `colors_json`（例: ["U","R"]） / `color_identity_json`
  - `type_line`（例: "Legendary Creature — Elf"）
  - `power`, `toughness`, `loyalty`（nullable）
  - `legalities_json`（各フォーマットごとの legal/banned/restricted）
  - `image_uris_json`（小/大/アートなど）
  - `card_faces_json`（MDFC/Transform/Saga 等の面情報をJSONで）
  - `scryfall_id`（将来のインポート用に保持、オフライン時は未使用可）

- **containers**（デッキ）
  - 追加: `format`（enum: standard/pioneer/modern/legacy/vintage/commander/pauper/oathbreaker/custom）
  - 追加: `commander_card_id FK`（Commander用。Partner/Companion は `extra_json` で拡張）
  - 追加: `extra_json`（companion, signature_spell など拡張用）

- **container_card_locations**
  - `location` は `main` / `side`（Commanderは通常 `side` 無効）

### 19.5 画面要件（追加/変更）
- **デッキ詳細**: フォーマットバッジ、マナカーブ（棒グラフ）、色分布（円）、タイプ構成、土地枚数を表示
- **カード追加パネル**: フィルタ（色、タイプ、mana_value、テキスト検索）
- **Commander UI**: コマンダー選択UI、色アイデンティティの可視化（バッジ）

### 19.6 インポート/エクスポート（将来）
- クリップボードのデッキリスト（Arena/MODO テキスト）インポート
- JSON エクスポート/インポート（オフライン前提）
- （将来）外部DB連携: Scryfall Bulk Data 取り込み

### 19.7 受け入れ基準（抜粋）
- **AC-MTG-STD-001**: Standard/60枚未満 → エラー「不足: X枚」
- **AC-MTG-STD-002**: 4枚超過のカードが存在 → 警告リスト表示
- **AC-MTG-VIN-001**: Vintage/制限カード2枚以上 → 警告（1枚に調整を提案）

### 19.8 マイグレーション
- **Schema v3** 例
  - `cards`: `mana_cost`, `mana_value`, `colors_json`, `color_identity_json`, `type_line`, `power`, `toughness`, `loyalty`, `legalities_json`, `image_uris_json`, `card_faces_json`, `scryfall_id` を追加
  - `containers`: `format`, `commander_card_id`, `extra_json` を追加
  - 既存データは `game != "MTG"` の行をそのまま保持（共存可能）

### 19.9 リスクと対策（MTG特有）
- **禁止/制限の頻繁な変更** → ルール集合を外部化（JSON）し、手動更新UIを提供
- **多面カードの扱い** → `card_faces_json` に一本化。検索・表示は面を選択可能
- **色アイデンティティ計算** → `color_identity_json` を基準とし、起動時に整合性チェック

### 19.10 KPI（MTG追加）
- 75枚（60+15）デッキの検証 ≤ 150ms
- マナカーブ/色分布チャート描画 ≤ 100ms
- 2,000枚カードローカル検索（色/タイプ/テキスト） ≤ 150ms
