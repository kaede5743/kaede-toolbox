import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

/// セクション見出し付きパネル(HTML版 .panel 相当)。
class SectionPanel extends StatelessWidget {
  const SectionPanel({
    super.key,
    required this.title,
    this.subtitle,
    required this.children,
  });

  final String title;
  final String? subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kc.panelTop, scheme.surface],
        ),
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: kc.accent,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(color: kc.accent.withValues(alpha: 0.7), blurRadius: 8),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 14,
                      color: kc.accent,
                      letterSpacing: 2,
                    ),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    subtitle!,
                    style: TextStyle(
                        fontSize: 11.5, color: scheme.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

/// ラベル付き入力フィールド。
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.onChanged,
    this.minLines,
    this.maxLines = 1,
    this.trailing,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final int? minLines;
  final int maxLines;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Flexible(
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 12.5, color: scheme.onSurfaceVariant)),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
          ),
          TextField(
            controller: controller,
            onChanged: onChanged,
            minLines: minLines,
            maxLines: maxLines,
            decoration: InputDecoration(hintText: hint),
          ),
        ],
      ),
    );
  }
}

/// 「🔗 共通」バッジ(日付共有の表示)。
class SharedBadge extends StatelessWidget {
  const SharedBadge({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: kc.accent.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text('🔗 $text',
          style: TextStyle(fontSize: 10.5, color: kc.accent)),
    );
  }
}

/// HTML版 .toggle 相当のスイッチ行。
class ToggleRow extends StatelessWidget {
  const ToggleRow({
    super.key,
    required this.label,
    this.sublabel,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String? sublabel;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: kc.inputFill,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => onChanged(!value),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Switch(value: value, onChanged: onChanged),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: const TextStyle(fontSize: 13)),
                    if (sublabel != null)
                      Text(sublabel!,
                          style: TextStyle(
                              fontSize: 11.5,
                              color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// コピーすると1.6秒だけ「コピーしました ✓」に変わるボタン。
class CopyButton extends StatefulWidget {
  const CopyButton({super.key, required this.label, required this.textToCopy});

  final String label;
  final String Function() textToCopy;

  @override
  State<CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.textToCopy()));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1600));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    final scheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: _copied ? const Color(0xFF34D39A) : kc.accent,
        foregroundColor:
            _copied ? const Color(0xFF04130C) : scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: _copy,
      child: Text(_copied ? 'コピーしました ✓' : widget.label),
    );
  }
}

/// 入力/出力パネルを幅に応じて1〜2カラムに並べる。
class ResponsiveColumns extends StatelessWidget {
  const ResponsiveColumns({super.key, required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 840) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: 20), right],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 20),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}
