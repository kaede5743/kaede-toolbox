import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kaede_toolbox/main.dart';
import 'package:kaede_toolbox/model/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

Future<AppState> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1500, 2800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  final state = AppState(prefs: SharedPreferencesAsync());
  await state.load();
  await tester.pumpWidget(KaedeApp(state: state));
  await tester.pump();
  return state;
}

/// デバウンス保存・フラッシュ表示のタイマーを消化してからテストを終える。
Future<void> settle(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 2600));
}

void main() {
  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('起動時に告知タブとプレビューが表示される', (tester) async {
    await pumpApp(tester);
    expect(find.text('NIGHT RACE 配信告知メーカー'), findsOneWidget);
    expect(find.text('📣 配信告知'), findsOneWidget);
    // プレビューに DEFAULTS の投稿文が出ている
    expect(find.textContaining('「#TRCゆる部 ナイトレース」'), findsWidgets);
    expect(find.textContaining('レース15分前から配信始めるね✨'), findsWidgets);
    await settle(tester);
  });

  testWidgets('タイトル入力がプレビューと文字数に反映される', (tester) async {
    final state = await pumpApp(tester);
    await tester.enterText(
        find.widgetWithText(TextField, '#TRCゆる部 ナイトレース'), '新タイトル');
    await tester.pump();
    expect(state.title, '新タイトル');
    expect(find.textContaining('「新タイトル」'), findsWidgets);
    await settle(tester);
  });

  testWidgets('QRトグルOFFで案内文が消える', (tester) async {
    final state = await pumpApp(tester);
    expect(find.textContaining('QRから観戦モード'), findsWidgets);
    await tester.tap(find.text('QR観戦モードの案内'));
    await tester.pump();
    expect(state.qr, isFalse);
    expect(
        find.textContaining('細かい結果が知りたい方はQRから観戦モードにアクセスしてね。'), findsNothing);
    await settle(tester);
  });

  testWidgets('サムネタブでプロンプト生成できる', (tester) async {
    final state = await pumpApp(tester);
    await tester.tap(find.text('🎨 サムネプロンプト'));
    await tester.pumpAndSettle();
    expect(state.tab, 'thumb');
    expect(find.text('かえでちゃんねる サムネプロンプト'), findsOneWidget);

    // メインタイトルを入れて生成
    await tester.enterText(
        find.widgetWithText(TextField, 'TRCゆる部').first, 'ゆる部');
    await tester.pump();
    await tester.ensureVisible(find.text('✨ プロンプトを生成する'));
    await tester.tap(find.text('✨ プロンプトを生成する'));
    await tester.pump();
    expect(state.output, contains('【サムネイル画像 編集プロンプト】'));
    expect(state.output, contains('「ゆる部」'));
    await settle(tester);
  });

  testWidgets('バッジモードは未入力だとエラーメッセージ', (tester) async {
    final state = await pumpApp(tester);
    await tester.tap(find.text('🎨 サムネプロンプト'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('かえでちゃんねる賞'));
    await tester.pumpAndSettle();
    expect(state.editMode, 'badgeOnly');
    expect(find.textContaining('バッジ1行目'), findsOneWidget);

    await tester.ensureVisible(find.text('✨ プロンプトを生成する'));
    await tester.tap(find.text('✨ プロンプトを生成する'));
    await tester.pump();
    // エラーは出力欄に表示され、state.output(保存対象)は変わらない
    expect(find.textContaining('バッジの文字を少なくとも1つ入力してください。'), findsOneWidget);
    expect(state.output, isEmpty);
    await settle(tester);
  });

  testWidgets('レース内容の行を追加・削除できる', (tester) async {
    final state = await pumpApp(tester);
    await tester.tap(find.text('🎨 サムネプロンプト'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('レース内容を追加'));
    await tester.tap(find.text('レース内容を追加'));
    await tester.pump();
    expect(find.widgetWithText(TextField, '例：ヒート戦'), findsNWidgets(2));

    await tester.tap(find.byTooltip('削除').first);
    await tester.pump();
    expect(find.widgetWithText(TextField, '例：ヒート戦'), findsNWidgets(1));
    expect(state.contents.length, 1);
    await settle(tester);
  });

  testWidgets('保存された状態が次回起動時に復元される', (tester) async {
    final state = await pumpApp(tester);
    await tester.enterText(
        find.widgetWithText(TextField, '#TRCゆる部 ナイトレース'), '保存テスト');
    await tester.pump();
    await settle(tester); // デバウンス保存を発火させる

    // 同じ(インメモリ)ストレージで新しい AppState を起動
    final state2 = AppState(prefs: SharedPreferencesAsync());
    expect(await state2.load(), isTrue);
    expect(state2.title, '保存テスト');
    expect(state.title, state2.title);
  });
}
