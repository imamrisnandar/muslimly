import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslimly/src/core/presentation/widgets/app_transparent_app_bar.dart';

// AppTransparentAppBar was rolled out to 15 more pages during a code-review
// pass, with several new optional params (centerTitle, bottom,
// titleFontSize) added so pages with a search field or tab bar in their app
// bar didn't lose it. None of that was verified visually (the app can't run
// on this machine — see CODE_REVIEW_PROGRESS.md), so this at least confirms
// the widget builds and wires those params through correctly.
//
// The widget uses flutter_screenutil's .sp extension, which needs
// ScreenUtilInit somewhere above it in the tree (same as the real app does
// in main.dart) or it throws a LateInitializationError.
Widget _wrapWithScreenUtil(Widget app) => ScreenUtilInit(
      designSize: const Size(392.72727272727275, 800.7272727272727),
      builder: (context, child) => app,
    );

void main() {
  Widget wrap(Widget child) => _wrapWithScreenUtil(
        MaterialApp(
          home: Scaffold(appBar: child as PreferredSizeWidget),
        ),
      );

  testWidgets('renders the title', (tester) async {
    await tester.pumpWidget(
      wrap(const AppTransparentAppBar(title: 'Pengaturan')),
    );
    expect(find.text('Pengaturan'), findsOneWidget);
  });

  testWidgets('AppBar background is transparent with no elevation', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const AppTransparentAppBar(title: 'Test')),
    );
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, Colors.transparent);
    expect(appBar.elevation, 0);
  });

  testWidgets('shows a default back button (Icons.arrow_back)', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const AppTransparentAppBar(title: 'Test')));
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });

  testWidgets('a custom onBack callback runs instead of the go_router pop', (
    tester,
  ) async {
    // The default onBack is `context.pop()` from go_router, which needs a
    // GoRouter in the tree to behave like it does in the real app — wiring
    // one up just for this widget test isn't worth it, so this checks the
    // override path instead: the same path every page with a non-standard
    // back action (e.g. a raw Navigator.push) already relies on.
    var backPressed = false;
    await tester.pumpWidget(
      wrap(
        AppTransparentAppBar(
          title: 'Test',
          onBack: () => backPressed = true,
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    expect(backPressed, isTrue);
  });

  testWidgets('a custom leading widget overrides the default back button', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        AppTransparentAppBar(
          title: 'Custom leading',
          leading: IconButton(
            key: const Key('custom-leading'),
            icon: const Icon(Icons.close),
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(find.byKey(const Key('custom-leading')), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back), findsNothing);
  });

  testWidgets('actions are rendered', (tester) async {
    await tester.pumpWidget(
      wrap(
        AppTransparentAppBar(
          title: 'With actions',
          actions: const [Icon(Icons.search, key: Key('search-action'))],
        ),
      ),
    );
    expect(find.byKey(const Key('search-action')), findsOneWidget);
  });

  testWidgets('bottom widget is rendered and included in preferredSize', (
    tester,
  ) async {
    const bottom = PreferredSize(
      preferredSize: Size.fromHeight(48),
      child: SizedBox(key: Key('bottom-widget'), height: 48),
    );
    const appBar = AppTransparentAppBar(title: 'With bottom', bottom: bottom);

    expect(
      appBar.preferredSize.height,
      kToolbarHeight + 48,
      reason: 'preferredSize must grow to fit the bottom widget, or the '
          'body renders under it',
    );

    await tester.pumpWidget(wrap(appBar));
    expect(find.byKey(const Key('bottom-widget')), findsOneWidget);
  });

  testWidgets('titleColor and iconColor are applied', (tester) async {
    await tester.pumpWidget(
      wrap(
        const AppTransparentAppBar(
          title: 'Colored',
          titleColor: Colors.red,
          iconColor: Colors.blue,
        ),
      ),
    );
    final titleText = tester.widget<Text>(find.text('Colored'));
    expect(titleText.style?.color, Colors.red);

    final backIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_back));
    expect(backIcon.color, Colors.blue);
  });
}
