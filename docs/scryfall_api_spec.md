# Scryfall API 連携仕様
最終更新日: 2025-09-24

## 概要
CardPro Flutter クライアントでは Scryfall が提供する REST API を利用してカード名の補完、カード詳細の検索、印刷一覧およびローカライズされた名称を取得する。本書は現行実装で参照しているエンドポイントと、主要なクエリパラメータ・レスポンス項目・フォールバック処理を整理する。

## ベース URL
- `https://api.scryfall.com`

## 認証とレート制限
- API キーは不要（Scryfall 公開 API を利用）。
- Scryfall 推奨の User-Agent 送信（`package/version (+contact)`）を追加予定。現行実装では未設定。
- レート制限: 1 クライアントあたり最大およそ 10 リクエスト/秒。サーバから `429` が返った場合は指数的バックオフで再試行すること。

## 共通 HTTP 設定
- ライブラリ: `package:http`。
- タイムアウト: 10 秒（`http.get(...).timeout(Duration(seconds: 10))`）。
- エラー処理: `statusCode != 200` の場合は空配列または `null` を返却し、UI では「候補なし」扱い。
- 日本語判定: `/[\u3040-\u30FF\u4E00-\u9FFF]/` に一致した場合は日本語クエリとみなし、フォールバック検索を追加で実行。

## 利用エンドポイント

### 1. カード名補完
- メソッド: `GET`
- パス: `/cards/autocomplete`
- クエリパラメータ:
  | パラメータ | 備考 |
  | --- | --- |
  | `q` | ユーザー入力を `trim` し、`Uri.encodeQueryComponent` した文字列。空文字はリクエストしない。 |
  | `include_multilingual` | 常に `true`。多言語（日本語含む）の候補を取得する。 |
- 主なレスポンス項目:
  - `total_items` (int): 候補件数。
  - `data` (string[]): 補完候補。アプリ側で最大 20 件まで利用。
- フォールバック: 日本語クエリの場合 `_searchJapaneseNames` を追加実行し、`printed_name` を前方一致で取得。重複は `Set` で除去し、日本語候補を優先してマージ。

### 2. カード検索
- メソッド: `GET`
- パス: `/cards/search`
- 共通クエリパラメータ:
  | パラメータ | 主な設定値 | 用途 |
  | --- | --- | --- |
  | `q` | 検索式 | Scryfall の高度検索構文を利用。 |
  | `unique` | `prints` / `cards` | `prints`: 同一カードの異なる刷りを全て取得。`cards`: Oracle ID 単位で重複排除。 |
  | `order` | `released` / `name` | 取得順。日本語補完では `name`、刷り一覧では `released` を使用。 |
- 利用パターン:
  1. **日本語補完 (`_searchJapaneseNames`)**
     - `q=lang:ja name:<入力値>` → 前方一致で printed_name を取得。
     - ヒットしない場合 `q=lang:ja <入力値>` にフォールバック。
     - レスポンスの `data[].printed_name` を利用。無い場合は `card_faces[0].printed_name` → `name` の順で補完。
  2. **多言語名称からカード特定 (`getCardByExactName`)**
     - `q=name:"<入力値>"&unique=prints&order=released`
     - 日本語などで `named` API が 404 の場合に利用。最初の要素を `ScryfallCard.fromJson` でパース。
  3. **刷り一覧 (`listPrintings`)**
     - 日本語クエリ: `q=lang:ja name:"<入力値>"&unique=prints&order=released`
     - 英語クエリ: `q=!"<入力値>"&unique=prints&order=released`
     - レスポンスの `data[]` を全件パースしてリスト表示。
  4. **Oracle ID から英日名称取得 (`getLocalizedNamesByOracleId`)**
     - 英語: `q=oracleid:<id>&unique=cards&order=released`
     - 日本語: `q=oracleid:<id> lang:ja&unique=prints&order=released`
     - `data[0].name` を英語名称、`data[0].printed_name` または `card_faces[].printed_name` を日本語名称として採用。
- ページング: 現行実装では未対応。デフォルトの 175 件/ページ以内に収まる想定。必要に応じて `page` パラメータを追加すること。

### 3. 名称完全一致取得
- メソッド: `GET`
- パス: `/cards/named`
- クエリパラメータ:
  | パラメータ | 備考 |
  | --- | --- |
  | `exact` | 英語の Oracle 名を完全一致で指定。 |
- レスポンス: 1 枚のカードオブジェクト。成功時は `ScryfallCard.fromJson` でパース。
- フォールバック: 404 や `statusCode != 200` の場合は `cards/search`（パターン 2）に切り替える。

## レスポンスから利用しているフィールド
`ScryfallCard` モデルで参照する主なキーと意味は以下の通り。

| Scryfall キー | 型 | 用途 |
| --- | --- | --- |
| `name` | string | 英語 Oracle 名。UI のデフォルト表示。 |
| `printed_name` | string? | ローカライズ名（日本語優先）。無い場合は `card_faces[0].printed_name` を探索。 |
| `set` | string? | セットコード（例: `lea`）。 |
| `set_name` | string? | セット表示名。 |
| `collector_number` | string? | カード番号。数字以外を含む場合あり。 |
| `rarity` | string? | レアリティ。必要に応じて `C/U/R/M` に変換。 |
| `lang` | string? | 言語コード（例: `en`, `ja`）。 |
| `released_at` | string? | 発売日 (`yyyy-mm-dd`)。 |
| `oracle_id` | string | Oracle ID。ローカライズ名取得や刷り一覧で利用。 |
| `card_faces` | array? | 両面カード等で `printed_name` を補完する際に参照。 |

## エラーおよび再試行ポリシー
- ネットワーク例外／タイムアウト発生時は `catch` で `null` を返却し、UI 側でエラーダイアログや再試行を検討する。
- `429` や `503` を受けた場合は待機後に再試行する実装を検討（現行は未対応のため今後の改善事項）。
- ステータス 404 の場合は「該当カードなし」として処理。

## 今後の TODO
- User-Agent および `Accept: application/json` ヘッダーの明示設定。
- レート制限超過時のバックオフ実装。
- `cards/search` でのページング対応と `has_more` フラグのハンドリング。
- 自動テスト用のモックレスポンス整備。

## 変更履歴
- 2025-09-24: 初版作成。
