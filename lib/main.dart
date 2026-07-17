import 'package:flutter/material.dart';

import 'model/app_state.dart';
import 'pages/post_page.dart';
import 'pages/thumb_page.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final state = AppState();
  await state.load();
  runApp(KaedeApp(state: state));
}

class KaedeApp extends StatelessWidget {
  const KaedeApp({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) => MaterialApp(
        title: 'かえで配信ツールボックス',
        debugShowCheckedModeBanner: false,
        theme: state.tab == 'post' ? postTheme : thumbTheme,
        home: HomePage(state: state),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: state,
      builder: (context, _) {
        final kc = Theme.of(context).extension<KaedeColors>()!;
        final scheme = Theme.of(context).colorScheme;
        final isPost = state.tab == 'post';
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // ---- ヘッダー ----
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: scheme.outlineVariant)),
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: scheme.outline),
                                boxShadow: [
                                  BoxShadow(
                                      color: kc.accent.withValues(alpha: 0.14),
                                      spreadRadius: 3),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: const Text('🍁',
                                  style: TextStyle(fontSize: 21)),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPost
                                        ? 'NIGHT RACE 配信告知メーカー'
                                        : 'かえでちゃんねる サムネプロンプト',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontSize: 20),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text.rich(
                                    TextSpan(children: [
                                      const TextSpan(text: '変わるところだけ入力 → '),
                                      TextSpan(
                                          text: 'コピーして使う',
                                          style: TextStyle(
                                              color: kc.accent,
                                              fontWeight: FontWeight.w600)),
                                      const TextSpan(
                                          text: '。入力内容は自動で保存されるよ。'),
                                    ]),
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: scheme.onSurfaceVariant),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ]),
                          const SizedBox(height: 14),
                          Row(children: [
                            _TabButton(
                              label: '📣 配信告知',
                              active: isPost,
                              onTap: () =>
                                  state.update(() => state.tab = 'post'),
                            ),
                            const SizedBox(width: 6),
                            _TabButton(
                              label: '🎨 サムネプロンプト',
                              active: !isPost,
                              onTap: () =>
                                  state.update(() => state.tab = 'thumb'),
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
                // ---- 本体 ----
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: IndexedStack(
                          index: isPost ? 0 : 1,
                          children: [
                            PostPage(state: state),
                            ThumbPage(state: state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final kc = Theme.of(context).extension<KaedeColors>()!;
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          color: active ? kc.panelTop : Colors.transparent,
          border: Border.all(
              color: active ? scheme.outline : scheme.outlineVariant),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              width: 60,
              margin: const EdgeInsets.only(top: 2),
              decoration: BoxDecoration(
                color: active ? kc.accent : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: active ? scheme.onSurface : scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
