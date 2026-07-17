import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// タブごとのテーマカラー。post=ナイトレース(シアン)、thumb=かえでちゃんねる(ピンク)。
class KaedeColors extends ThemeExtension<KaedeColors> {
  const KaedeColors({
    required this.accent,
    required this.accentDeep,
    required this.warn,
    required this.hashtag,
    required this.panelTop,
    required this.inputFill,
  });

  final Color accent;
  final Color accentDeep;
  final Color warn;
  final Color hashtag;
  final Color panelTop;
  final Color inputFill;

  @override
  KaedeColors copyWith({
    Color? accent,
    Color? accentDeep,
    Color? warn,
    Color? hashtag,
    Color? panelTop,
    Color? inputFill,
  }) =>
      KaedeColors(
        accent: accent ?? this.accent,
        accentDeep: accentDeep ?? this.accentDeep,
        warn: warn ?? this.warn,
        hashtag: hashtag ?? this.hashtag,
        panelTop: panelTop ?? this.panelTop,
        inputFill: inputFill ?? this.inputFill,
      );

  @override
  KaedeColors lerp(KaedeColors? other, double t) {
    if (other == null) return this;
    return KaedeColors(
      accent: Color.lerp(accent, other.accent, t)!,
      accentDeep: Color.lerp(accentDeep, other.accentDeep, t)!,
      warn: Color.lerp(warn, other.warn, t)!,
      hashtag: Color.lerp(hashtag, other.hashtag, t)!,
      panelTop: Color.lerp(panelTop, other.panelTop, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
    );
  }
}

const _ink = Color(0xFF070912);

ThemeData _base({
  required Color accent,
  required Color accentDeep,
  required Color warn,
  required Color surface,
  required Color surface2,
  required Color text,
  required Color muted,
  required TextStyle Function({TextStyle? textStyle}) headFont,
}) {
  final scheme = ColorScheme.dark(
    primary: accent,
    onPrimary: const Color(0xFF0B0510),
    secondary: accentDeep,
    surface: _ink,
    surfaceContainer: surface,
    surfaceContainerHigh: surface2,
    onSurface: text,
    onSurfaceVariant: muted,
    error: warn,
    outline: Colors.white.withValues(alpha: 0.14),
    outlineVariant: Colors.white.withValues(alpha: 0.08),
  );
  final noto = GoogleFonts.notoSansJpTextTheme(ThemeData.dark().textTheme)
      .apply(bodyColor: text, displayColor: text);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: _ink,
    textTheme: noto.copyWith(
      titleLarge: headFont(textStyle: noto.titleLarge)
          .copyWith(fontWeight: FontWeight.w700, letterSpacing: 1),
      labelSmall: noto.labelSmall?.copyWith(color: muted),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface2,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: accent, width: 1.6),
      ),
      hintStyle: TextStyle(color: muted.withValues(alpha: 0.6)),
      labelStyle: TextStyle(color: muted, fontSize: 13),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accent : null),
      trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? accentDeep : null),
    ),
    extensions: [
      KaedeColors(
        accent: accent,
        accentDeep: accentDeep,
        warn: warn,
        hashtag: const Color(0xFF7FB8FF),
        panelTop: surface,
        inputFill: surface2,
      ),
    ],
  );
}

/// 告知タブ: ナイトレース(シアン)
final ThemeData postTheme = _base(
  accent: const Color(0xFF36E2E6),
  accentDeep: const Color(0xFF0C8B8F),
  warn: const Color(0xFFFF6452),
  surface: const Color(0xFF0F1426),
  surface2: const Color(0xFF161D34),
  text: const Color(0xFFEAF0FF),
  muted: const Color(0xFF8A93AD),
  headFont: GoogleFonts.rajdhani,
);

/// サムネタブ: かえでちゃんねる(ピンク)
final ThemeData thumbTheme = _base(
  accent: const Color(0xFFFF6FB5),
  accentDeep: const Color(0xFFD61F8D),
  warn: const Color(0xFFFFCF57),
  surface: const Color(0xFF2B1030),
  surface2: const Color(0xFF3A1440),
  text: const Color(0xFFFFE6F5),
  muted: const Color(0xFFC98FB8),
  headFont: GoogleFonts.kosugiMaru,
);
