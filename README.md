# かえで配信ツールボックス 🍁

配信告知文とサムネイル編集用AIプロンプトを生成するWebアプリ(Flutter Web製)。

**公開URL: https://kaede5743.github.io/kaede-toolbox/**

スマホ・PCどちらのブラウザからでも使えます。入力内容は端末ごとに自動保存されます。

## 機能

- **📣 配信告知タブ** — タイトル・日時・本文などを入力すると、X(Twitter)用の告知文を組み立ててプレビュー。文字数メーター(X換算)付き。ワンタップでコピー。
- **🎨 サムネプロンプトタブ** — レース情報を入力すると、画像編集AI(image-to-image)に渡すサムネイル編集プロンプトを生成。「かえでちゃんねる賞」バッジ専用モードあり。
- 配信日付は両タブで共有。入力は自動保存され、次回開いたときに復元されます。

## 開発

```sh
flutter pub get
flutter test          # ロジック・UIテスト
flutter run -d chrome # ローカル実行
```

## 更新の反映

コードを変更したら、PowerShell でデプロイスクリプトを実行すると
ビルドして GitHub Pages (gh-pages ブランチ) に公開されます。

```powershell
.\deploy.ps1
```

ソースコード自体の保存は通常どおり:

```sh
git add -A
git commit -m "変更内容"
git push
```
