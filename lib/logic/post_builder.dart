/// 告知文の組み立て・文字数計算。HTML版 kaede-stream-toolbox.html の
/// buildPostText / fmtDate / weightedLength と同一の出力になるよう移植している。
library;

const String kDivider = '⋆┈┈┈┈┈┈┈┈┈┈┈┈┈┈┈⋆';
const String kQrLine = '細かい結果が知りたい方はQRから観戦モードにアクセスしてね。';
const String kRrLine = '総当たり戦については、スマホで入力してくれた人しかリアルタイムに反映されないので、結果が出るのは全試合後になるのでごめんね';

/// "2026-06-13" → "06/13(土)"。パースできない場合は入力をそのまま返す。
String fmtDate(String raw) {
  if (raw.isEmpty) return '';
  final parts = raw.split('-').map(int.tryParse).toList();
  if (parts.length < 3 || parts.any((p) => p == null)) return raw;
  final dt = DateTime(parts[0]!, parts[1]!, parts[2]!);
  final w = '日月火水木金土'[dt.weekday % 7];
  final mm = parts[1].toString().padLeft(2, '0');
  final dd = parts[2].toString().padLeft(2, '0');
  return '$mm/$dd($w)';
}

class PostInput {
  const PostInput({
    required this.title,
    required this.date,
    required this.time,
    required this.body,
    required this.minutes,
    required this.url,
    required this.tags,
    required this.qr,
    required this.rr,
  });

  final String title;
  final String date; // yyyy-MM-dd
  final String time; // HH:mm
  final String body;
  final String minutes;
  final String url;
  final String tags;
  final bool qr;
  final bool rr;
}

String buildPostText(PostInput s) {
  final lines = <String>[
    kDivider,
    '「${s.title}」',
    '${fmtDate(s.date)} ${s.time}配信スタート!!',
    kDivider,
    '',
    s.body,
    '',
    'レース${s.minutes}分前から配信始めるね✨',
    if (s.qr) ...['', kQrLine],
    if (s.rr) ...['', kRrLine],
    '',
    '待機所${s.url}',
    '',
    s.tags,
  ];
  return lines.join('\n');
}

final RegExp _urlRe = RegExp(r'https?://\S+');

/// X(Twitter)換算の文字数。URLは一律23、東アジア幅広文字は2、他は1。
int weightedLength(String text) {
  final urls = _urlRe.allMatches(text).length;
  final stripped = text.replaceAll(_urlRe, '');
  var count = urls * 23;
  for (final cp in stripped.runes) {
    final wide = (cp >= 0x1100 && cp <= 0x115F) ||
        (cp >= 0x2E80 && cp <= 0xA4CF) ||
        (cp >= 0xAC00 && cp <= 0xD7A3) ||
        (cp >= 0xF900 && cp <= 0xFAFF) ||
        (cp >= 0xFE30 && cp <= 0xFE4F) ||
        (cp >= 0xFF00 && cp <= 0xFF60) ||
        (cp >= 0xFFE0 && cp <= 0xFFE6) ||
        (cp >= 0x20000 && cp <= 0x3FFFD) ||
        (cp >= 0x3040 && cp <= 0x30FF);
    count += wide ? 2 : 1;
  }
  return count;
}
