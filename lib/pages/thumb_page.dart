import 'package:flutter/material.dart';

import '../logic/prompt_builder.dart';
import '../model/app_state.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 🎨 サムネプロンプトタブ
class ThumbPage extends StatefulWidget {
  const ThumbPage({super.key, required this.state});

  final AppState state;

  @override
  State<ThumbPage> createState() => _ThumbPageState();
}

class _ThumbPageState extends State<ThumbPage> {
  late final TextEditingController _mainTitle;
  late final TextEditingController _subTitle;
  late final TextEditingController _eventSub;
  late final TextEditingController _charText;
  late final TextEditingController _badge1;
  late final TextEditingController _badge2;
  late final TextEditingController _badgeDate;
  late final TextEditingController _extraNote;
  late final TextEditingController _output;
  final List<TextEditingController> _contents = [];
  String _note = '入力すると自動で保存されるよ。';

  static const _placeholder = 'まだ生成されていません。左側の項目を入力して「プロンプトを生成する」を押してください。';

  AppState get s => widget.state;

  @override
  void initState() {
    super.initState();
    _mainTitle = TextEditingController(text: s.mainTitle);
    _subTitle = TextEditingController(text: s.subTitle);
    _eventSub = TextEditingController(text: s.eventSub);
    _charText = TextEditingController(text: s.charText);
    _badge1 = TextEditingController(text: s.badgeLine1);
    _badge2 = TextEditingController(text: s.badgeLine2);
    _badgeDate = TextEditingController(text: s.badgeDate);
    _extraNote = TextEditingController(text: s.extraNote);
    _output = TextEditingController(
        text: s.output.isNotEmpty ? s.output : _placeholder);
    for (final v in s.contents) {
      _contents.add(TextEditingController(text: v));
    }
  }

  @override
  void dispose() {
    for (final c in [
      _mainTitle, _subTitle, _eventSub, _charText,
      _badge1, _badge2, _badgeDate, _extraNote, _output,
      ..._contents,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  ThumbInput get _input => ThumbInput(
        mainTitle: s.mainTitle,
        subTitle: s.subTitle,
        eventSub: s.eventSub,
        contents: s.contents,
        date: s.date,
        charText: s.charText,
        badgeLine1: s.badgeLine1,
        badgeLine2: s.badgeLine2,
        badgeDate: s.badgeDate,
        extraNote: s.extraNote,
        qualityMode: s.qualityMode,
      );

  void _generate() {
    final r = s.editMode == 'badgeOnly'
        ? buildBadgePrompt(_input)
        : buildNormalPrompt(_input);
    setState(() => _output.text = r.text);
    if (!r.isError) {
      s.update(() => s.output = r.text);
      _flash('プロンプトを生成したよ');
    }
  }

  void _clear() {
    s.resetThumb();
    _mainTitle.clear();
    _subTitle.clear();
    _eventSub.clear();
    _charText.clear();
    _badge1.clear();
    _badge2.clear();
    _badgeDate.clear();
    _extraNote.clear();
    for (final c in _contents) {
      c.dispose();
    }
    _contents
      ..clear()
      ..add(TextEditingController());
    _output.text = _placeholder;
    _flash('サムネの入力をクリアしたよ（日付は共通なのでそのまま）');
  }

  void _flash(String msg) {
    setState(() => _note = msg);
    Future<void>.delayed(const Duration(milliseconds: 2400)).then((_) {
      if (mounted) setState(() => _note = '入力すると自動で保存されるよ。');
    });
  }

  void _syncContents() {
    s.update(() => s.contents = _contents.map((c) => c.text).toList());
  }

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

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) => ResponsiveColumns(
        left: _inputPanel(context),
        right: _outputPanel(context),
      ),
    );
  }

  Widget _inputPanel(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    final scheme = Theme.of(context).colorScheme;
    final isBadge = s.editMode == 'badgeOnly';

    return SectionPanel(
      title: 'DESIGN / レース情報を入力',
      subtitle: 'プロンプトの材料',
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('編集モード',
                    style: TextStyle(
                        fontSize: 12.5, color: scheme.onSurfaceVariant)),
              ),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'full', label: Text('サムネイル')),
                  ButtonSegment(value: 'badgeOnly', label: Text('かえでちゃんねる賞')),
                ],
                selected: {s.editMode},
                onSelectionChanged: (sel) =>
                    s.update(() => s.editMode = sel.first),
                style: ButtonStyle(
                  textStyle: WidgetStateProperty.all(const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
        ToggleRow(
          label: '文字の変更と同時に、全体の画質もアップさせる',
          value: s.qualityMode,
          onChanged: (v) => s.update(() => s.qualityMode = v),
        ),
        const SizedBox(height: 4),
        if (isBadge)
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(children: [
              AppTextField(
                label: 'バッジ1行目（上段の小さい文字／例：なごネット）',
                hint: '例：なごネット',
                controller: _badge1,
                onChanged: (v) => s.update(() => s.badgeLine1 = v),
              ),
              AppTextField(
                label: 'バッジ2行目（中央の大会名／例：中日新聞D4チケ戦）',
                hint: '例：中日新聞D4チケ戦',
                controller: _badge2,
                onChanged: (v) => s.update(() => s.badgeLine2 = v),
              ),
              AppTextField(
                label: 'バッジ日付（下段の日付／例：2026/06/21）',
                hint: '例：2026/06/21',
                controller: _badgeDate,
                onChanged: (v) => s.update(() => s.badgeDate = v),
              ),
            ]),
          )
        else ...[
          AppTextField(
            label: 'メインタイトル（例：TRCゆる部）',
            hint: 'TRCゆる部',
            controller: _mainTitle,
            onChanged: (v) => s.update(() => s.mainTitle = v),
          ),
          AppTextField(
            label: 'サブタイトル（レース名）（例：ナイトレース）',
            hint: 'ナイトレース',
            controller: _subTitle,
            onChanged: (v) => s.update(() => s.subTitle = v),
          ),
          AppTextField(
            label: 'イベント副題（☆～　～☆ で挟まれる1行／不要なら空欄でOK）',
            hint: '例：スイッチさんお誕生日おめでとうレース',
            controller: _eventSub,
            onChanged: (v) => s.update(() => s.eventSub = v),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('レース内容（♪☆で装飾される項目／複数追加できます）',
                      style: TextStyle(
                          fontSize: 12.5, color: scheme.onSurfaceVariant)),
                ),
                for (var i = 0; i < _contents.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Expanded(
                        child: TextField(
                          controller: _contents[i],
                          decoration:
                              const InputDecoration(hintText: '例：ヒート戦'),
                          onChanged: (_) => _syncContents(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: '削除',
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          setState(() {
                            _contents.removeAt(i).dispose();
                          });
                          _syncContents();
                        },
                      ),
                    ]),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _contents.add(TextEditingController()));
                      _syncContents();
                    },
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('レース内容を追加'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Text('日付',
                        style: TextStyle(
                            fontSize: 12.5, color: scheme.onSurfaceVariant)),
                    const SizedBox(width: 8),
                    const SharedBadge(text: '告知と共通'),
                  ]),
                ),
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(s.date.isEmpty ? '日付を選ぶ' : s.date),
                ),
              ],
            ),
          ),
          AppTextField(
            label: 'キャラクター周りの文字（ヘッドホン・パソコン画面・DJ機材にまとめて反映）',
            hint: '例：TRCゆる部',
            controller: _charText,
            onChanged: (v) => s.update(() => s.charText = v),
          ),
        ],
        AppTextField(
          label: 'その他の指定（任意／色味の微調整やフォント指定など自由記述）',
          hint: '例：今回はハートを少し多めに／サブタイトルの水色を少し濃くしたい　など',
          controller: _extraNote,
          minLines: 2,
          maxLines: 4,
          onChanged: (v) => s.update(() => s.extraNote = v),
        ),
        Row(children: [
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: kc.accent,
                foregroundColor: scheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                textStyle:
                    const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _generate,
              child: const Text('✨ プロンプトを生成する'),
            ),
          ),
          const SizedBox(width: 10),
          TextButton(
            onPressed: _clear,
            child: Text('入力をクリア',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: kc.accent.withValues(alpha: 0.10),
            border: Border(left: BorderSide(color: kc.accent, width: 3)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            noteText(isBadge),
            style: TextStyle(
                fontSize: 11.5, color: scheme.onSurfaceVariant, height: 1.6),
          ),
        ),
      ],
    );
  }

  Widget _outputPanel(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionPanel(
      title: 'PROMPT / 生成されたプロンプト',
      subtitle: '画像編集AIに渡す指示文',
      children: [
        TextField(
          controller: _output,
          readOnly: true,
          minLines: 14,
          maxLines: 30,
          style: const TextStyle(fontSize: 13, height: 1.75),
          decoration: InputDecoration(
            fillColor: Colors.black.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(height: 16),
        CopyButton(
          label: 'プロンプトをコピーする',
          textToCopy: () => _output.text,
        ),
        const SizedBox(height: 10),
        Text(_note,
            style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
