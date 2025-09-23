# ER 図（PlantUML）

カード管理アプリの Drift 実装（`lib/db`）のテーブル定義に合わせた ER 図です。PlantUML 対応環境で貼り付けると図として確認できます。

- `mtg_cards` は言語別のカード名、印刷情報、効果参照を保持します。`oracle_id` はユニーク制約付きの任意値です。
- `card_instances` は所持しているカード個体を表します。コンテナとの対応は中間表 `container_card_locations` で管理します。
- `containers` はデッキや整理用の入れ物を表し、`is_active` でアクティブなデッキを示します。
- `container_card_locations` は 1 枚のカード個体がどのコンテナのどの区分（main/side 等）にあるかを管理する複合主キーを持つ表です。

```plantuml
@startuml
left to right direction

entity "CARD_EFFECTS" as card_effects {
  *id : INTEGER
  --
  name : TEXT
  description : TEXT
}

entity "MTG_CARDS" as mtg_cards {
  *id : INTEGER
  --
  name : TEXT
  name_en : TEXT <<NULLABLE>>
  name_ja : TEXT <<NULLABLE>>
  rarity : TEXT <<NULLABLE>>
  set_name : TEXT <<NULLABLE>>
  cardnumber : INTEGER <<NULLABLE>>
  oracle_id : TEXT <<UNIQUE>> <<NULLABLE>>
  effect_id : INTEGER <<FK>>
}

entity "CARD_INSTANCES" as card_instances {
  *id : INTEGER
  --
  card_id : INTEGER <<FK>>
  updated_at : DATETIME <<NULLABLE>>
  description : TEXT <<NULLABLE>>
}

entity "CONTAINERS" as containers {
  *id : INTEGER
  --
  name : TEXT <<NULLABLE>>
  description : TEXT <<NULLABLE>>
  container_type : TEXT
  is_active : BOOLEAN <<DEFAULT:false>>
}

entity "CONTAINER_CARD_LOCATIONS" as container_card_locations {
  *container_id : INTEGER <<FK>>
  *card_instance_id : INTEGER <<FK>>
  *location : TEXT
}

card_effects ||--o{ mtg_cards : provides
mtg_cards ||--o{ card_instances : owns
card_instances ||--o{ container_card_locations : allocated_in
containers ||--o{ container_card_locations : holds

@enduml
```
