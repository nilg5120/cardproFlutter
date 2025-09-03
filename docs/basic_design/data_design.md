# データ設計 - CardPro

## 1. 方針
- Clean Architecture の Domain/Repository 境界を尊重し、Drift で永続化。
- 正規化: カード効果は `card_effects` に集約し重複排除。
- 参照整合性: 外部キー相当はアプリ側で保全（Driftの参照/結合で担保）。

## 2. テーブル定義（Drift）

### pokemon_cards（lib/db/pokemon_cards.dart）
- id: int, PK, autoIncrement
- name: text, 必須
- rarity: text, nullable
- setName: text, nullable
- cardnumber: int, nullable
- effectId: int, FK → card_effects.id

### card_instances（lib/db/card_instances.dart）
- id: int, PK, autoIncrement
- cardId: int, 必須（pokemon_cards.id 参照）
- updatedAt: datetime, nullable
- description: text, nullable

### card_effects（lib/db/card_effects.dart）
- id: int, PK, autoIncrement
- name: text, 必須
- description: text, 必須

### containers（lib/db/containers.dart）
- id: int, PK, autoIncrement
- name: text, nullable（表示名）
- description: text, nullable
- containerType: text, 必須（'deck','drawer','binder'など）

### container_card_locations（lib/db/container_card_locations.dart）
- containerId: int, PK(part)
- cardInstanceId: int, PK(part)
- location: text, PK(part)（'main','side'）

複合PK: (containerId, cardInstanceId, location)

## 3. リレーションとルール
- pokemon_cards 1 - n card_instances（カード定義と実体）
- containers 1 - n container_card_locations（デッキと中身）
- location は列挙（main/side）として扱う。
- containers.containerType は 'deck' を基準に実装（将来、保管庫等も同スキーマで併存）

## 4. インデックス/性能
- container_card_locations: (containerId, location) の複合索引を検討
- card_instances: cardId 索引でカード単位取得を高速化
- pokemon_cards: name 前方一致用の索引は将来の検索導入時に付与

## 5. マイグレーション
- schemaVersion=1（`lib/db/database.dart`）。将来の変更は Drift の migration を用意
- 破壊的変更は基本禁止。追加・非NULL化は移行手順（デフォルト埋め）を設計

## 6. 代表クエリ
- カード定義 + 実体一覧: `AppDatabase.getCardWithMaster()` 参照（joinで取得）
- カード効果一覧: `select(cardEffects).get()`

## 7. データ初期化
- `ensureDefaultCardEffectsExist()` でデフォルト効果を投入
- 初期カード投入は任意のインポート（将来導入）

