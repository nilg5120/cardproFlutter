# DB 詳細設計（カード管理）

## 前提/方針
- 効果は任意（`mtg_cards.effect_id` は NULL 可、参照削除時は SET NULL）。
- 物理カードは「現在位置のみ」を保持（履歴は持たない）。
- 命名は snake_case、`card_number` は TEXT（例: 123a に対応）。

## テーブル定義

### CARD_EFFECTS
- id: INTEGER PK
- name: TEXT NOT NULL
- description: TEXT NULL
- 制約/索引
  - PK(id)

### MTG_CARDS
- id: INTEGER PK
- name: TEXT NOT NULL
- rarity: TEXT NOT NULL
- set_name: TEXT NOT NULL
- card_number: TEXT NOT NULL
- effect_id: INTEGER NULL FK → card_effects(id) ON DELETE SET NULL
- 制約/索引
  - UNIQUE(set_name, card_number) 例: 同一セット内で番号一意
  - INDEX(effect_id)

### CONTAINERS
- id: INTEGER PK
- name: TEXT NOT NULL
- description: TEXT NULL
- container_type: TEXT NOT NULL
- is_active: BOOLEAN NOT NULL DEFAULT 1
- 制約/索引
  - INDEX(is_active)

### CARD_INSTANCES
- id: INTEGER PK
- card_id: INTEGER NOT NULL FK → mtg_cards(id) ON DELETE CASCADE
- container_id: INTEGER NOT NULL FK → containers(id) ON DELETE RESTRICT
- location: TEXT NULL
- updated_at: DATETIME NOT NULL（例: DEFAULT CURRENT_TIMESTAMP）
- description: TEXT NULL
- 制約/索引
  - INDEX(card_id)
  - INDEX(container_id)

## ER 関係
- card_effects (0..1) — (0..N) mtg_cards
- mtg_cards (1) — (0..N) card_instances
- containers (1) — (0..N) card_instances

## 参考DDL（RDB汎用SQL方言）
```sql
CREATE TABLE card_effects (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT
);

CREATE TABLE mtg_cards (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  rarity TEXT NOT NULL,
  set_name TEXT NOT NULL,
  card_number TEXT NOT NULL,
  effect_id INTEGER,
  FOREIGN KEY (effect_id) REFERENCES card_effects(id) ON DELETE SET NULL,
  UNIQUE (set_name, card_number)
);
CREATE INDEX idx_mtg_cards_effect_id ON mtg_cards(effect_id);

CREATE TABLE containers (
  id INTEGER PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  container_type TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT 1
);
CREATE INDEX idx_containers_active ON containers(is_active);

CREATE TABLE card_instances (
  id INTEGER PRIMARY KEY,
  card_id INTEGER NOT NULL,
  container_id INTEGER NOT NULL,
  location TEXT,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  description TEXT,
  FOREIGN KEY (card_id) REFERENCES mtg_cards(id) ON DELETE CASCADE,
  FOREIGN KEY (container_id) REFERENCES containers(id) ON DELETE RESTRICT
);
CREATE INDEX idx_card_instances_card_id ON card_instances(card_id);
CREATE INDEX idx_card_instances_container_id ON card_instances(container_id);
```

## 運用メモ
- 文字コードは UTF-8（BOMなし）で統一（既存のER図Markdownに文字化けが見られたため修正済み）。
- 将来拡張でセットを正規化する場合は `mtg_sets(code, name, release_date...)` を設け、`mtg_cards.set_code` に置換し UNIQUE(set_code, card_number) へ移行。
- `location` はフリーテキストのため、固定棚番などを使う場合は正規化（`locations` テーブル）を検討。
```

