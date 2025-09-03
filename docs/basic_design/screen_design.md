# 画面設計 - CardPro

## 1. 対象と目的
本書は CardPro の画面構成、遷移、主要UI、イベントと状態管理(BLoC)の対応を示す。

## 2. 画面一覧と目的
- ホーム: 機能入口（カード/デッキ）
- カード一覧: 登録カードの一覧、検索・並び替え（将来）
- カード追加/編集ダイアログ: カード基本情報・効果・メモ
- デッキ一覧: コンテナ（deck）の一覧
- デッキ詳細: デッキ内カード（main/side）の一覧・編集
- デッキ使用（補完指示）: 物理移動の補助指示の提示と完了操作

参考資料: `docs/ux_scenarios/deck_card_move_flow.md`, `docs/wireframe.html`
ワイヤーフレーム: `docs/uml/wireframes_salt.puml`

## 3. 画面遷移
- ホーム → カード一覧 / デッキ一覧
- カード一覧 → 追加/編集ダイアログ
- デッキ一覧 → デッキ詳細
- デッキ詳細 → デッキ使用（補完指示） → 完了

遷移図: `docs/uml/screenl_flow.puml`

## 4. 主要UIと状態
- リスト表示: 無限スクロールは当面不要、空状態/エラー/読込中を明示
- フィルタ/検索: 将来追加時は状態とURLパラメータ風の保存方針を検討
- 操作の確定: 破壊的操作（削除・移動完了）は確認ダイアログ

## 5. BLoC 対応（概要）
- Cards
  - Event: LoadCards, AddCard, EditCard, DeleteCard
  - State: Loading, Loaded(list), Failure(error)
- Decks
  - Event: LoadDecks, AddDeck, EditDeck, DeleteDeck
  - State: Loading, Loaded(list/detail), Failure
- DeckUsage（将来追加）
  - Event: ComputeSuggestions(deckId), ConfirmMovement()
  - State: Computing, Suggested(list of instructions), Confirmed, Failure

表示要件（補完指示）:
- 列: カード名 / 移動元 / 移動先 / 枚数 / 場所(main/side)
- 操作: 「移動完了」ボタンで確定（ConfirmMovement）

## 6. バリデーションとエラー
- デッキ名重複の防止（入力時チェック）
- カード枚数上限の警告（将来のルール導入時）
- フォーム必須項目（カード名/デッキ名）

## 7. アクセシビリティ/ローカライズ
- テキストコントラストとタップ領域を確保
- 日本語既定。将来は `Intl` による多言語化を検討
