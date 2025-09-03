# 基本設計書 - CardPro

## 1. 目的
本書は CardPro（ポケモンカード等のコレクション管理・デッキ構築アプリ）の基本設計を示し、実装・テストの共通理解を提供する。対象読者は開発者およびレビュー担当。更新は要件・仕様変更に合わせて随時行う。

## 2. 対象範囲
- 対象: カード管理、デッキ管理、デッキ使用時のカード移動補助（UXシナリオ準拠）
- 非対象: オンライン同期、共有機能、OCR 等（将来拡張）
- 前提: ローカル SQLite（Drift）、オフライン前提、単一ユーザー

## 3. システム概要
- コンセプト: 「カード情報の一元管理」と「デッキ運用の実作業をアプリが補助」
- 主要ユースケース:
  - カード CRUD、効果の共通管理、カードメモ（インスタンス単位）
  - デッキ CRUD、デッキへのカード割り当て（main/side）
  - デッキ使用時の不足/余剰の診断と移動補助指示の提示
- 全体構成: Flutter + Clean Architecture（Presentation / Domain / Data）+ Drift(SQLite) + BLoC + GetIt

## 4. アーキテクチャ
- レイヤ構成:
  - Presentation: `pages/`, `widgets/`, `bloc/`（状態管理は BLoC）
  - Domain: `entities/`, `repositories/`(IF), `usecases/`
  - Data: `models/`, `datasources/`, `repositories/`(Impl)
- 依存方針: 依存は外側→内側のみ。Domain は純 Dart。UI からは UseCase を介して Data へ到達。
- DI: GetIt による依存解決（`lib/core/di/injection_container.dart`）。
- エラーハンドリング: `dartz.Either<Failure, T>` により成功/失敗を型で表現（`lib/core/error/failures.dart`）。

## 5. 機能設計（抜粋）

### 5.1 デッキ使用時のカード移動補助
- 入力: デッキID
- 処理概要:
  1) デッキ構成（main/side）を取得
  2) 枚数・必須カード等のルールを検査（将来拡張を見据え拡張可能に）
  3) 不足/余剰の算出（他デッキ/保管庫の在庫と突き合わせ）
  4) 「どのカードをどこからどこへ何枚」移すかの指示一覧を生成
- 出力: 補完指示リスト（例: カード名・移動元/先・枚数・場所属性）
- 例外/異常系: デッキ未存在、データ不整合、在庫不足、ルール未設定
- 成果物: 補完指示画面に表示し、ユーザーが物理移動後に「移動完了」アクションで確定

参考 UX: `docs/ux_scenarios/deck_card_move_flow.md`

### 5.2 カード管理
- カードの追加/編集/削除、カード効果の共通化（重複排除）、カードインスタンスごとのメモ付与。

### 5.3 デッキ管理
- デッキの作成/編集/削除、カードの割り当て（main/side）。

## 6. 画面設計（概要）
- 画面一覧: ホーム、カード一覧/追加・編集、デッキ一覧、デッキ詳細、デッキ使用（補完指示）
- 遷移: 一覧 → 詳細/ダイアログ、デッキ詳細 → 使用フロー → 完了
- UI要点（補完指示）:
  - 列: カード名 / 移動元 / 移動先 / 枚数 / 場所(main/side)
  - 操作: 「移動完了」ボタンで確認・確定

## 7. データ設計（主要）
- テーブル（Drift 定義に準拠）
  - `pokemon_cards`: カード基本情報
  - `card_instances`: 実体（メモ付与）
  - `card_effects`: 効果（共通化）
  - `containers`: デッキ（コンテナ）
  - `container_card_locations`: デッキ内のカード配置（main/side）
- 永続化ルール
  - 効果は正規化し重複を排除
  - デッキ内カードは場所属性を列挙型で管理（main/side）
  - 実体単位で自由メモを保持

## 8. インタフェース設計（概要）
- Repository IF（Domain）
  - `CardsRepository`, `DeckRepository` … UseCase から利用
- UseCase（例）
  - Cards: `GetCards`, `AddCard`, `EditCard`, `DeleteCard`, `EditCardFull`
  - Decks: `GetDecks`, `AddDeck`, `EditDeck`, `DeleteDeck`
- Presentation（BLoC 概要）
  - Cards: `CardBloc`（Event: load/add/edit/delete、State: loading/success/failure）
  - Decks: `DeckBloc`（同上）
  - DeckUsage（将来追加想定）: 補完指示算出/確定の Event/State を定義
- バリデーション
  - デッキ名重複、カード枚数上限、場所列挙の妥当性

## 9. 非機能
- 性能: 一覧/検索の応答性確保（必要に応じインデックス設計）
- 信頼性: DB 例外の捕捉とユーザ通知、ロールバック戦略
- 運用: BLoC トランジションログ、例外ログの収集
- セキュリティ: ローカル前提。将来の同期時に暗号化・認証を検討

## 10. テスト方針
- Unit: UseCase、Repository 実装、モデル変換、バリデーション
- Widget: 一覧/詳細/ダイアログ表示と操作、BLoC 統合
- カバレッジ目安: 主要 UseCase/Widget で 70–80%

## 11. 環境/ビルド
- 対応 OS: Flutter が対応する主要プラットフォーム
- 主要ライブラリ: Flutter, Drift, flutter_bloc, get_it, dartz, equatable
- 初期化順序: DI 登録 → DB 初期化 → 画面起動

## 12. マイグレーション/初期データ
- Drift スキーマのバージョン管理
- 初期カード投入は任意（将来インポート機能で対応）

## 13. リスク/課題
- 画面増加に伴う状態肥大化 → BLoC 分割と Selector 導入
- 検索/絞り込みの性能 → インデックス・クエリ最適化
- 将来同期のための ID 仕様 → UUID 等の一意性確保

## 14. 参照資料
- 要件定義: `docs/cardpro_requirements.md`
- UX シナリオ: `docs/ux_scenarios/deck_card_move_flow.md`
- 画面遷移（UML）: `docs/uml/screenl_flow.puml`
- 構成概要: `README.md`

