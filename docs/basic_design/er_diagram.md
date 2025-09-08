# ER 図 概要 / PlantUML
以下は現在の論理データモデルを表す ER 図です。PlantUML 対応環境で可視化できます。
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
  rarity : TEXT
  set_name : TEXT
  card_number : TEXT
  effect_id : INTEGER <<FK>>
}

entity "CONTAINERS" as containers {
  *id : INTEGER
  --
  name : TEXT
  description : TEXT
  container_type : TEXT
  is_active : BOOLEAN
}

entity "CARD_INSTANCES" as card_instances {
  *id : INTEGER
  --
  card_id : INTEGER <<FK>>
  container_id : INTEGER <<FK>>
  location : TEXT
  updated_at : DATETIME
  description : TEXT
}

' 関係（効果は任意: effect_id は NULL 可）
card_effects o|--o{ mtg_cards : referenced_by
mtg_cards    ||--o{ card_instances : instantiates
containers   ||--o{ card_instances : holds

@enduml
```

