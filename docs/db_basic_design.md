# データベース基本設計書（CardPro）

## 1. 目的・範囲
- 目的: MTGカード管理（マスタ・所持個体）およびデッキ構築、カード効果参照を行う。
- 対象: カードマスタ、カード個体、コンテナ（デッキ等）、配置中間テーブル、カード効果。
- 想定ユースケース:
  - カード一覧・検索
  - デッキ作成・編集・構築
  - カード効果の参照
  - 初期データ（シード）の自動投入

## 2. 技術スタック
- DB: SQLite（モバイルは `drift_sqflite`、デスクトップは `sqflite_common_ffi`）
- ORM: Drift（コード生成 `part 'database.g.dart'`）
- ストレージ配置: アプリのドキュメントディレクトリ配下 `cards.db`
- DI: GetIt による `AppDatabase` ライフサイクル管理

## 3. 物理構成（接続/配置）
- 接続: `LazyDatabase` による遅延オープン。SQL ログ出力（`logStatements: true`）。
- パス: `getApplicationDocumentsDirectory()`/`path.join(..., 'cards.db')`
- テスト: `AppDatabase.test(super.executor)` でテスト用 Executor を注入可能。

## 4. 論理データモデル（スキーマ）

### 4.1 MtgCards（カードマスタ）
- 主キー: `id` INTEGER AUTOINCREMENT
- 必須: `name` TEXT
- 任意: `rarity` TEXT, `setName` TEXT, `cardnumber` INTEGER
- 外部キー: `effectId` INTEGER → `CardEffects.id`
- 用途: マスタ属性の保持（名称、レアリティ、収録情報、効果）

### 4.2 CardInstances（カード個体）
- 主キー: `id` INTEGER AUTOINCREMENT
- 必須: `cardId` INTEGER（MTGカードマスタ参照を想定）
- 任意: `updatedAt` DATETIME, `description` TEXT
- 用途: ユーザーが所持する実体（同一マスタから複数存在）

### 4.3 Containers（コンテナ）
- 主キー: `id` INTEGER AUTOINCREMENT
- 必須: `containerType` TEXT（例: `deck`, `drawer`, `binder`）
- 任意: `name` TEXT, `description` TEXT
- 用途: デッキや保管場所など、カード個体を入れる入れ物の表現

### 4.4 ContainerCardLocations（配置・中間テーブル）
- 複合主キー: `(containerId, cardInstanceId, location)`
- 必須: `containerId` INTEGER, `cardInstanceId` INTEGER, `location` TEXT（例: `main`, `side`）
- 用途: 多対多（Containers × CardInstances）と、入れ物内での配置区分の表現

### 4.5 CardEffects（カード効果マスタ）
- 主キー: `id` INTEGER AUTOINCREMENT
- 必須: `name` TEXT, `description` TEXT
- 用途: カード効果の名称・説明

## 5. エンティティ関係（ER 概要）
- `CardEffects (1) — (N) MtgCards`
- `MtgCards (1) — (N) CardInstances`
- `Containers (N) — (N) CardInstances`（中間 `ContainerCardLocations` により表現、`location` で配置区分）

## 6. 主なユースケースと API（抜粋）
- 効果一覧取得: `getAllCardEffects()`
- 個体 + マスタ結合取得: `getCardWithMaster()`
- 初期データ投入:
  - 効果: `ensureDefaultCardEffectsExist()`
  - 初期カード/デッキ: `ensureInitialCardsAndDeckExist()`

## 7. 初期データ（Seed）
- 効果（例）: 「基本効果」「エネルギー加速」「ダメージ増加」
- マスタ: 稲妻、対抗呪文、ラノワールのエルフ（いずれも既定効果を参照）
- 個体: 上記マスタに対応する個体を複数作成
- デッキ: `containerType = 'deck'` の初期デッキを1件作成し、個体を `main` に配置

## 8. 制約・インデックス（推奨方針）
- 外部キー制約（Drift の `references` 推奨）
  - `CardInstances.cardId → MtgCards.id`
  - `ContainerCardLocations.containerId → Containers.id`
  - `ContainerCardLocations.cardInstanceId → CardInstances.id`
- インデックス
  - `CardInstances(cardId)`
  - `MtgCards(effectId)`
  - `ContainerCardLocations(containerId, location)` / `ContainerCardLocations(cardInstanceId)`
- 削除ポリシー
  - `ContainerCardLocations` は `ON DELETE CASCADE` を推奨
  - マスタ（MtgCards / CardEffects）は `RESTRICT` またはアプリ層での参照ガード

## 9. マイグレーション
- 現行スキーマバージョン: `1`
- 変更時: `schemaVersion` をインクリメントし、`MigrationStrategy` を実装
  - 列追加: `ALTER TABLE` + 既存データのデフォルト値補填
  - 破壊的変更: 一時テーブル移送 or アプリ層での移行 + 再シード

## 10. DI/初期化
- `GetIt` で `AppDatabase` を `registerLazySingleton` 登録
- アプリ起動時に以下を実行
  - `ensureDefaultCardEffectsExist()`
  - `ensureInitialCardsAndDeckExist()`

## 11. 非機能要件
- パフォーマンス: 結合・参照列へのインデックス、必要列のみの SELECT
- 可搬性: モバイル/デスクトップ両対応（`drift_sqflite` / `sqflite_common_ffi`）
- ログ: SQL ログ出力をデバッグ用に有効化
- 可観測性: DB パスを `debugPrint` で出力し、サポート容易化
- テスト容易性: メモリ/テスト DB への差し替えパスを確保

## 12. 改善提案（任意）
- 参照整合性の強化: 上記外部キーの `references` 化と `CASCADE`/`RESTRICT` の明示
- 監査列の追加: `createdAt`, `updatedAt`（全テーブル）
- デッキ拡張: `format`, `notes`, `sideboard` 規則の明確化
- マスタ拡張: `type`, `subtype`, `hp`, `attacks` など将来拡張の余地

## 13. 未確定事項（要件確認）
- デッキ構成ルール（メイン/サイド、上限枚数）
- 検索要件（レアリティ・効果名・テキスト全文検索の要否）
- 削除ポリシー（論理削除の採否、復元要件）
- 変更履歴の保持粒度（個体/デッキ編集の履歴化）

---
更新履歴: 初版（このファイルの追加）
