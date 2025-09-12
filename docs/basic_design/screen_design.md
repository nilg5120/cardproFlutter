# 画面設計 - CardPro（実装準拠版）

最終更新: 2025-09-10（現行実装に合わせて記述）

## 1. 目的
現行アプリの画面構成、遷移、主要UI、BLoCイベント/ステートの対応関係を示します。過去案からの差分（未実装/簡素化）は備考に明記します。

## 2. 画面一覧と目的（実装）
| 画面 | ファイル | 概要 |
|------|---------|------|
| ホーム | `lib/features/home/presentation/pages/home_page.dart` | エントリー。Cards / Decks / Containers へ遷移 |
| カード一覧 | `lib/features/cards/presentation/pages/card_list_page.dart` | カードを「oracleId」でグルーピング表示（同一 oracle を1種類として扱う）。FABで追加。エンプティ/エラー/ローディング対応 |
| カード追加ダイアログ | `lib/features/cards/presentation/widgets/add_card_dialog.dart` | Scryfall オートコンプリート対応。Rarity/Set/Card No./Effect/メモ/数量を入力して追加 |
| カード個体一覧 | `lib/features/cards/presentation/pages/card_instances_page.dart` | 同名カードの個体を「Set名」でグルーピング表示。削除/編集（メモのみ or メタ含む） |
| デッキ一覧 | `lib/features/decks/presentation/pages/deck_list_page.dart` | デッキ一覧。追加/削除/「使用中にする」。詳細へ遷移 |
| デッキ詳細 | `lib/features/decks/presentation/pages/deck_detail_page.dart` | デッキ名/説明の編集。デッキ内カード一覧（Location表示）。未割当カードの追加、カードの取り外し |
| コンテナ一覧 | `lib/features/containers/presentation/pages/container_list_page.dart` | 物理保管「コンテナ」の一覧。追加/削除。詳細へ遷移 |
| コンテナ詳細 | `lib/features/containers/presentation/pages/container_detail_page.dart` | 名称/種類/説明の編集。コンテナ内カード一覧。未割当カードの追加、カードの取り外し |
| デッキ使用（移動指示）ダイアログ | `lib/features/decks/presentation/widgets/deck_list_item.dart` | 「使用中にする」操作時に、現在の使用中デッキと重複するカード個体を一覧表示し、物理移動の完了を促す確認ダイアログ |

参考: `docs/ux_scenarios/deck_card_move_flow.md`, `docs/wireframe.html`
ワイヤーフレーム
- Home: `docs/uml/wireframes/home.puml`
- Cards（一覧）: `docs/uml/wireframes/cards_list.puml`
- Cards（追加/編集ダイアログ）: `docs/uml/wireframes/card_add_edit_dialog.puml`
- Decks（一覧）: `docs/uml/wireframes/decks_list.puml`
- Deck（詳細）: `docs/uml/wireframes/deck_detail.puml`
- Deck Usage（移動指示）: `docs/uml/wireframes/deck_usage_move_instructions_dialog.puml`
- まとめ: `docs/uml/wireframes_salt.puml`

## 3. 画面遷移（実装）
- ホーム → カード一覧 / デッキ一覧 / コンテナ一覧
- カード一覧 → カード追加ダイアログ / カード個体一覧
- デッキ一覧 → デッキ詳細 / 「使用中にする」→ 移動指示ダイアログ → 確定 → 使用中切替
- コンテナ一覧 → コンテナ詳細
- デッキ詳細 →（未割当カードを追加：モーダルシート）/（カードを取り外し）

遷移図: `docs/uml/screenl_flow.puml`

## 4. 主要UI/UX
- リスト状態: 読み込み中（スピナー）、エラー（文言/再試行）、空状態を実装
- 検索/フィルタ: カード一覧の検索・並び替えは未実装（将来対応）
- 追加/編集:
  - カード追加は Scryfall との連携で名称候補・印刷情報補完
  - カード編集はメモのみ or Rarity/Set/Card No.も含む完全編集の両対応
- 確認ダイアログ: デッキ/コンテナ削除、カード削除、デッキ使用切替時の移動完了確認を実装
- グルーピング表示: カード一覧=名前単位、個体一覧=Set名単位
- Location 取扱い: デッキ追加時は現在 `main` 固定で登録。`side` 切替は未対応（一覧には表示）/ コンテナは `storage` を使用

## 5. BLoC 対応（実装）
### Cards（`lib/features/cards/presentation/bloc`）
- Event: `GetCardsEvent`, `AddCardEvent`, `EditCardEvent`, `EditCardFullEvent`, `DeleteCardEvent`
- State: `CardInitial`, `CardLoading`, `CardLoaded(List<CardWithInstance>)`, `CardError`

### Decks（`lib/features/decks/presentation/bloc`）
- Event: `GetDecksEvent`, `AddDeckEvent`, `DeleteDeckEvent`, `EditDeckEvent`, `SetActiveDeckEvent`
- State: `DeckInitial`, `DeckLoading`, `DeckLoaded(List<Container>)`, `DeckError`

### Containers（`lib/features/containers/presentation/bloc`）
- Event: `GetContainersEvent`, `AddContainerEvent`, `EditContainerEvent`, `DeleteContainerEvent`
- State: `ContainerInitial`, `ContainerLoading`, `ContainerLoaded(List<Container>)`, `ContainerError`

### Deck Usage（備考）
- 専用BLoCは未実装。`DeckListItem` 内でDBクエリにより「現在の使用中デッキ」との重複個体を抽出し、移動指示のリストを表示→ユーザーが物理移動完了後に確定→`SetActiveDeckEvent` を送出して切替。

## 6. バリデーション/エラー
- 必須入力: デッキ名、コンテナ名/種類、カード追加時の名称（数量は未入力・0/負数は1に丸め）
- 数値入力: Card No./数量は数値のみ受理（不正は無視または丸め）
- 重複名の禁止: 画面上の重複チェックは未実装（DB側の整合性に依存）
- Scryfall連携: 候補取得失敗時はエラーアイコン表示（致命エラーにはしない）

## 7. アクセシビリティ/ローカライズ
- Material 3 を使用。ボタン/タッチ領域は標準に準拠
- 文言は英語主体＋一部日本語。完全な多言語化は未実装

## 8. 既存ドキュメントからの主な差分
- 以前案の Deck Usage 用 BLoC（`ComputeSuggestions`/`ConfirmMovement`）は未実装。現状はデッキ切替時ダイアログで代替
- ワイヤーファイル名: `deck_usage_move_instructions_dialog.puml` に変更（実体に合わせて修正）
- 画面に「コンテナ」機能が追加されているため、一覧/詳細を追記
- カード一覧の検索/並び替えは未対応（当面不要）
