/// サムネプロンプトの組み立て。HTML版 kaede-stream-toolbox.html の
/// buildNormalPrompt / buildBadgePrompt / qualityBlock / fmtSlashDate と
/// 同一の出力になるよう移植している。文面は1文字も変えないこと。
library;

/// "2026-06-13" → "2026/06/13"
String fmtSlashDate(String dateStr) {
  if (dateStr.isEmpty) return '';
  final p = dateStr.split('-');
  return p.join('/');
}

class PromptResult {
  const PromptResult.ok(this.text) : isError = false;
  const PromptResult.error(this.text) : isError = true;

  final String text;
  final bool isError;
}

class ThumbInput {
  const ThumbInput({
    this.mainTitle = '',
    this.subTitle = '',
    this.eventSub = '',
    this.contents = const [],
    this.date = '',
    this.charText = '',
    this.badgeLine1 = '',
    this.badgeLine2 = '',
    this.badgeDate = '',
    this.extraNote = '',
    this.qualityMode = true,
  });

  final String mainTitle;
  final String subTitle;
  final String eventSub;
  final List<String> contents;
  final String date; // yyyy-MM-dd
  final String charText;
  final String badgeLine1;
  final String badgeLine2;
  final String badgeDate;
  final String extraNote;
  final bool qualityMode;
}

String qualityBlock({required bool enabled, required bool badge}) {
  if (!enabled) return '';
  if (badge) {
    return '\n\n■ 同時に画質も向上させる\n上記のテキスト差し替えと同時に、バッジ以外の部分も含めて画像全体の解像度・描き込みクオリティを引き上げてください。\n・線画やディテールの解像度を上げ、輪郭のガタつきやノイズを解消する\n・グラデーションやハイライトを滑らかにする\n・全体的なノイズやにじみを除去し、高解像度でクリアな仕上がりにする\n（ただし、キャラクターやレイアウトなど、テキスト以外のデザインは一切変更しないこと）';
  }
  return '\n\n■ 同時に画質も向上させる\n上記のテキスト差し替えと同時に、画像全体の解像度・描き込みクオリティも引き上げてください。\n・線画やディテールの解像度を上げ、輪郭のガタつきやノイズを解消する\n・グラデーションやハイライトを滑らかにする\n・髪・リボン・衣装・ぬいぐるみ・機材の質感やディテールをより緻密に描き込む\n・全体的なノイズやにじみを除去し、高解像度でクリアな仕上がりにする\n（ただし、キャラクターのデザイン・ポーズ・配色・構図は変更しないこと）';
}

PromptResult buildBadgePrompt(ThumbInput s) {
  final b1 = s.badgeLine1.trim();
  final b2 = s.badgeLine2.trim();
  final bd = s.badgeDate.trim();
  final extra = s.extraNote.trim();

  if (b1.isEmpty && b2.isEmpty && bd.isEmpty) {
    return const PromptResult.error('バッジの文字を少なくとも1つ入力してください。');
  }

  return PromptResult.ok('''【バッジ内テキストのみ 差し替えプロンプト】

添付した画像をベースに、画像編集（image-to-image）で以下の指示に従い、画像内の「バッジ」部分のテキストだけを差し替えてください。それ以外の要素は一切変更しないでください。

■ 絶対に変更しないもの
・バッジ以外の画像全体（キャラクターイラスト、背景の配色・装飾、テキストバナーなど）は、添付画像から一切変更せず、そのまま維持してください。
・バッジの装飾要素（ティアラのアイコン、左右のリボン、下部の虹色の帯、バッジ全体のキラキラした縁取り・グラデーション背景）も、形状・色・配置ともに一切変更しないでください。
・バッジのサイズ・位置も変更しないでください。
・画像全体のアスペクト比（縦横比）は添付画像のまま維持し、トリミングや余白追加は行わないでください。

■ 差し替えるもの（バッジ内の文字のみ）
バッジ内の文字のフォントスタイル（縁取り・グラデーション・太さ）、行数（3行構成）は添付画像のまま維持し、各行の文字内容だけを以下に置き換えてください。

　1行目（上段の小さいテキスト）：「${b1.isNotEmpty ? b1 : '（指定なし・添付画像のまま）'}」
　2行目（中央の大きいテキスト・大会名/イベント名）：「${b2.isNotEmpty ? b2 : '（指定なし・添付画像のまま）'}」
　3行目（下段の日付）：「${bd.isNotEmpty ? bd : '（指定なし・添付画像のまま）'}」

・各行の文字数が変わって文字サイズや折り返しの微調整が必要になっても構いませんが、その場合もバッジの外枠サイズと装飾は変えないでください。${extra.isNotEmpty ? '\n\n■ その他の指定\n$extra' : ''}${qualityBlock(enabled: s.qualityMode, badge: true)}''');
}

PromptResult buildNormalPrompt(ThumbInput s) {
  final mainTitle = s.mainTitle.trim();
  final subTitle = s.subTitle.trim();
  final eventSub = s.eventSub.trim();
  final date = fmtSlashDate(s.date);
  final headphoneText = s.charText.trim();
  final extra = s.extraNote.trim();
  final contents =
      s.contents.map((v) => v.trim()).where((v) => v.isNotEmpty).toList();

  if (mainTitle.isEmpty && subTitle.isEmpty) {
    return const PromptResult.error('メインタイトルまたはサブタイトルを入力してください。');
  }

  final contentLine = contents.isNotEmpty
      ? contents.map((c) => '♪ ☆ $c ☆ ♪').join('\n　　')
      : '（レース内容の指定なし）';

  final eventSubBlock = eventSub.isNotEmpty
      ? '3. イベント副題（メインタイトルとレース内容の間・星アイコン「☆」で両端を挟んだ1行・ピンク文字・中央寄せ）：\n　　☆～$eventSub～☆\n'
      : '3. イベント副題：今回は指定なし。この行自体を省略してください。\n';

  return PromptResult.ok('''【サムネイル画像 編集プロンプト】

添付した参考画像（TRCゆる部ナイトレース サムネイル）をベースに、画像編集（image-to-image）で以下の指示に従い、同じ画風・同じレイアウト構成で左側のテキストエリアのみを差し替えてください。

■ 絶対に変更しないもの（参考画像から完全に維持）
・右側のキャラクターイラスト（ピンクツインテールの女の子、猫耳型ヘッドホン、DJミキサー、ぶたのぬいぐるみ、ノートPC、表情・ポーズ・衣装・配色）は、下記7で指定する文字部分（ヘッドホン・ノートPC画面・DJ機材の表示文字）以外、一切変更せず、そのまま維持してください。
・背景の配色（濃いピンク〜マゼンタの放射状グラデーション）、キラキラの粒子・星・ハートが散りばめられた装飾スタイルも同じように踏襲してください。
・画像全体のアスペクト比（縦横比）は参考画像のまま維持し、トリミングや余白追加は行わないでください。

■ 差し替えるテキストエリア（画面左側）
上から下へ、以下の内容・スタイルで再構成してください。

1. メインタイトル（最上部・比較的小さめ、ピンク〜ゴールドの斜めグラデーション文字、太い白〜金の縁取り＋ドロップシャドウ、近くに小さなリボン/ハートの装飾）：
　　「$mainTitle」

2. サブタイトル＝レース名（メインタイトルのすぐ下・最も大きい見出し文字、水色〜ピンクのグラデーション、太いアウトラインのぷっくりしたバブルレター、光沢ハイライト付き）：
　　「$subTitle」

${eventSubBlock}4. レース内容（音符「♪」と星「☆」のアイコンで両側を装飾した行。複数ある場合は縦に並べ、下に点線の区切り線を入れる）：
　　$contentLine

5. 日付（テキストブロックの一番下・最も大きいサイズの数字、紫〜ピンクのグラデーション、太いバブル体の立体的な数字）：
　　「${date.isNotEmpty ? date : '（日付未入力）'}」

6. 日付の下にハート柄の飾りスクロールライン（参考画像と同じ、両端がくるんと丸まった罫線装飾）を配置してください。

7. キャラクター周りの文字（ヘッドホン・ノートPC画面・DJミキサー等の機材に表示されている文字。この部分のみ変更可）：
　　「${headphoneText.isNotEmpty ? headphoneText : '（指定なし・参考画像のまま）'}」
　　（フォント・配置・サイズ感は参考画像のスタイルを踏襲し、各箇所の文字内容をすべてこの文字に差し替えてください）

■ 全体トーン
ポップでキュートな配信告知サムネイルとして、キラキラ・グリッター・星・ハートを画面全体に散りばめ、文字はすべて太い縁取り＋ドロップシャドウ付きのぷっくりしたバブルレターで統一してください。${extra.isNotEmpty ? '\n\n■ その他の指定\n$extra' : ''}${qualityBlock(enabled: s.qualityMode, badge: false)}''');
}

/// モードごとの案内文（HTML版 noteText）
String noteText(bool isBadge) => isBadge
    ? '画像生成AIに読み込ませる時は、「かえでちゃんねる賞」の画像を「添付画像」として渡し、このプロンプトをテキスト指示として使ってください。'
    : '画像生成AIに読み込ませる時は、いつもの参考サムネイル画像（右側の女の子が写っているもの）を「添付画像」として一緒に渡し、このプロンプトをテキスト指示として使ってください。';
