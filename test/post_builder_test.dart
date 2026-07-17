import 'package:flutter_test/flutter_test.dart';
import 'package:kaede_toolbox/logic/post_builder.dart';

void main() {
  group('fmtDate', () {
    test('曜日付きの MM/DD 形式になる', () {
      expect(fmtDate('2026-06-13'), '06/13(土)');
      expect(fmtDate('2026-07-18'), '07/18(土)');
      expect(fmtDate('2026-01-01'), '01/01(木)');
      expect(fmtDate('2026-06-14'), '06/14(日)');
    });

    test('不正な入力はそのまま返す', () {
      expect(fmtDate(''), '');
      expect(fmtDate('abc'), 'abc');
    });
  });

  group('buildPostText', () {
    // HTML版 DEFAULTS と同じ入力
    const defaults = PostInput(
      title: '#TRCゆる部 ナイトレース',
      date: '2026-06-13',
      time: '21:45',
      body: '今回は新しいレイアウトでの初レース♪\nどんなレースになるか楽しみ',
      minutes: '15',
      url: 'https://youtube.com/live/c8zrG_XybXk',
      tags: '#ミニ四駆 #レース配信 #かえで配信中',
      qr: true,
      rr: true,
    );

    test('DEFAULTS で HTML 版と同一の投稿文になる', () {
      expect(buildPostText(defaults), '''⋆┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈⋆
「#TRCゆる部 ナイトレース」
06/13(土) 21:45配信スタート!!
⋆┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈⋆

今回は新しいレイアウトでの初レース♪
どんなレースになるか楽しみ

レース15分前から配信始めるね✨

細かい結果が知りたい方はQRから観戦モードにアクセスしてね。

総当たり戦については、スマホで入力してくれた人しかリアルタイムに反映されないので、結果が出るのは全試合後になるのでごめんね

待機所https://youtube.com/live/c8zrG_XybXk

#ミニ四駆 #レース配信 #かえで配信中''');
    });

    test('QR/総当たりトグルOFFで該当行が消える', () {
      final text = buildPostText(const PostInput(
        title: 'T',
        date: '2026-06-13',
        time: '21:45',
        body: 'B',
        minutes: '15',
        url: 'https://example.com/x',
        tags: '#tag',
        qr: false,
        rr: false,
      ));
      expect(text.contains(kQrLine), isFalse);
      expect(text.contains(kRrLine), isFalse);
      expect(text, '''⋆┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈⋆
「T」
06/13(土) 21:45配信スタート!!
⋆┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈⋆

B

レース15分前から配信始めるね✨

待機所https://example.com/x

#tag''');
    });
  });

  group('weightedLength (X換算)', () {
    test('半角=1, 全角=2', () {
      expect(weightedLength('abc'), 3);
      expect(weightedLength('あいう'), 6);
      expect(weightedLength('aあ'), 3);
    });

    test('URLは一律23', () {
      expect(weightedLength('https://youtube.com/live/c8zrG_XybXk'), 23);
      // 見(2)+て(2)+空白(1) + URL(23) + 空白(1)+!(1)
      expect(weightedLength('見て https://example.com/aaaaa !'), 30);
    });

    test('絵文字・記号', () {
      // ✨ (U+2728) は wide 判定範囲外なので幅1（HTML版と同じ挙動）
      expect(weightedLength('✨'), 1);
    });
  });
}
