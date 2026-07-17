import 'package:flutter/material.dart';

import '../logic/post_builder.dart';
import '../model/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 📣 配信告知タブ
class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.state});

  final AppState state;

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  late final TextEditingController _title;
  late final TextEditingController _body;
  late final TextEditingController _minutes;
  late final TextEditingController _url;
  late final TextEditingController _tags;
  String _note = '入力すると自動で保存されるよ。';

  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: s.title);
    _body = TextEditingController(text: s.body);
    _minutes = TextEditingController(text: s.minutes);
    _url = TextEditingController(text: s.url);
    _tags = TextEditingController(text: s.tags);
  }

  @override
  void dispose() {
    _title.dispose();
    _body.dispose();
    _minutes.dispose();
    _url.dispose();
    _tags.dispose();
    super.dispose();
  }

  PostInput get _input => PostInput(
        title: s.title,
        date: s.date,
        time: s.time,
        body: s.body,
        minutes: s.minutes,
        url: s.url,
        tags: s.tags,
        qr: s.qr,
        rr: s.rr,
      );

  Future<void> _pickDate() async {
    final initial = DateTime.tryParse(s.date) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      s.update(() => s.date =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _pickTime() async {
    final parts = s.time.split(':').map(int.tryParse).toList();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
          hour: parts.isNotEmpty ? parts[0] ?? 21 : 21,
          minute: parts.length > 1 ? parts[1] ?? 0 : 0),
    );
    if (picked != null) {
      s.update(() => s.time =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}');
    }
  }

  void _reset() {
    s.resetPost();
    _title.text = s.title;
    _body.text = s.body;
    _minutes.text = s.minutes;
    _url.text = s.url;
    _tags.text = s.tags;
    _flash('最初の内容に戻したよ');
  }

  void _flash(String msg) {
    setState(() => _note = msg);
    Future<void>.delayed(const Duration(milliseconds: 2400)).then((_) {
      if (mounted) setState(() => _note = '入力すると自動で保存されるよ。');
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => ResponsiveColumns(
        left: _inputPanel(context),
        right: _previewPanel(context),
      ),
    );
  }

  Widget _inputPanel(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    return SectionPanel(
      title: 'PIT / 入力',
      subtitle: '毎回ここだけ書き換え',
      children: [
        AppTextField(
          label: 'タイトル',
          controller: _title,
          onChanged: (v) => s.update(() => s.title = v),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(children: [
                  Text('配信日時',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(width: 8),
                  const SharedBadge(text: '日付はサムネと共通'),
                  const SizedBox(width: 8),
                  Text('→ ${fmtDate(s.date)}',
                      style: TextStyle(fontSize: 12, color: kc.accent)),
                ]),
              ),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(s.date.isEmpty ? '日付を選ぶ' : s.date),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTime,
                    icon: const Icon(Icons.schedule, size: 18),
                    label: Text(s.time.isEmpty ? '時刻を選ぶ' : s.time),
                  ),
                ),
              ]),
            ],
          ),
        ),
        AppTextField(
          label: '今回の一言（本文）',
          hint: '今回は新しいレイアウトでの初レース♪\nどんなレースになるか楽しみ',
          controller: _body,
          minLines: 3,
          maxLines: 6,
          onChanged: (v) => s.update(() => s.body = v),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('配信スタートのタイミング',
                    style: TextStyle(
                        fontSize: 12.5,
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ),
              Row(children: [
                const Text('レース', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 10),
                SizedBox(
                  width: 84,
                  child: TextField(
                    controller: _minutes,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    onChanged: (v) => s.update(() => s.minutes = v),
                  ),
                ),
                const SizedBox(width: 10),
                const Text('分前から配信', style: TextStyle(fontSize: 13)),
              ]),
            ],
          ),
        ),
        AppTextField(
          label: '待機所URL',
          hint: 'https://youtube.com/live/...',
          controller: _url,
          onChanged: (v) => s.update(() => s.url = v),
        ),
        AppTextField(
          label: 'ハッシュタグ',
          controller: _tags,
          onChanged: (v) => s.update(() => s.tags = v),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text('追加の案内文（必要な回だけON）',
              style: TextStyle(
                  fontSize: 12.5,
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ),
        ToggleRow(
          label: 'QR観戦モードの案内',
          sublabel: '「細かい結果はQRから…」の一文を入れる',
          value: s.qr,
          onChanged: (v) => s.update(() => s.qr = v),
        ),
        ToggleRow(
          label: '総当たり戦の注意書き',
          sublabel: 'スマホ入力者のみ反映／結果は全試合後の説明',
          value: s.rr,
          onChanged: (v) => s.update(() => s.rr = v),
        ),
      ],
    );
  }

  Widget _previewPanel(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final text = buildPostText(_input);
    final len = weightedLength(text);
    final over = len > 280;

    return SectionPanel(
      title: 'BROADCAST / プレビュー',
      subtitle: '投稿される見た目',
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A0D18),
            border: Border.all(color: scheme.outline),
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: scheme.outline),
                    boxShadow: [
                      BoxShadow(
                          color: kc.accent.withValues(alpha: 0.14),
                          blurRadius: 0,
                          spreadRadius: 3),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text('🍁', style: TextStyle(fontSize: 18)),
                ),
                const SizedBox(width: 11),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('かえで',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5)),
                    Text('@kaede_live_ch',
                        style: TextStyle(
                            color: scheme.onSurfaceVariant, fontSize: 12.5)),
                  ],
                ),
              ]),
              const SizedBox(height: 12),
              _PreviewText(text: text),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          Text('文字数（X換算・目安）',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: (len / 280).clamp(0.0, 1.0),
                minHeight: 5,
                backgroundColor: kc.inputFill,
                color: over ? kc.warn : kc.accent,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$len / 280',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: over ? kc.warn : scheme.onSurface,
              )),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: CopyButton(
              label: '投稿文をコピーする',
              textToCopy: () => buildPostText(_input),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _reset,
            child: Text('最初の内容に戻す',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(_note,
            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}

/// URL・ハッシュタグ・区切り線・タイトルを色分けした投稿プレビュー。
class _PreviewText extends StatelessWidget {
  const _PreviewText({required this.text});

  final String text;

  static final _tokenRe = RegExp(r'(https?://\S+)|(#[^\s#]+)');

  @override
  Widget build(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    final lines = text.split('\n');
    final spans = <TextSpan>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line == kDivider) {
        spans.add(TextSpan(
            text: line, style: TextStyle(color: kc.accent, letterSpacing: 1)));
      } else if (i == 1 && line.startsWith('「')) {
        spans.add(TextSpan(
            text: line, style: const TextStyle(fontWeight: FontWeight.w700)));
      } else {
        var last = 0;
        for (final m in _tokenRe.allMatches(line)) {
          if (m.start > last) {
            spans.add(TextSpan(text: line.substring(last, m.start)));
          }
          if (m.group(1) != null) {
            spans.add(TextSpan(
                text: m.group(1),
                style: TextStyle(
                    color: kc.accent,
                    decoration: TextDecoration.underline,
                    decorationColor: kc.accent)));
          } else {
            spans.add(TextSpan(
                text: m.group(2), style: TextStyle(color: kc.hashtag)));
          }
          last = m.end;
        }
        if (last < line.length) {
          spans.add(TextSpan(text: line.substring(last)));
        }
      }
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(fontSize: 14, height: 1.7),
        children: spans,
      ),
    );
  }
}
