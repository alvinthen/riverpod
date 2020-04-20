import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:mockito/mockito.dart';
import 'package:provider_hooks/provider_hooks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Provider.value', () {
    testWidgets(
        "doesn't rebuild dependents when Provider.value update with == value",
        (tester) async {
      final useProvider = Provider.value(42);

      var buildCount = 0;
      final child = HookBuilder(builder: (c) {
        buildCount++;
        return Text(
          useProvider().toString(),
          textDirection: TextDirection.ltr,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            useProvider.overrideForSubtree(Provider.value(0)),
          ],
          child: child,
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            useProvider.overrideForSubtree(Provider.value(0)),
          ],
          child: child,
        ),
      );

      expect(buildCount, 1);
      expect(find.text('0'), findsOneWidget);
    });
    testWidgets('expose value as is', (tester) async {
      final useProvider = Provider.value(42);

      await tester.pumpWidget(
        ProviderScope(
          child: HookBuilder(builder: (c) {
            return Text(
              useProvider().toString(),
              textDirection: TextDirection.ltr,
            );
          }),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('override updates rebuild dependents with new value',
        (tester) async {
      final useProvider = Provider.value(0);
      final child = HookBuilder(builder: (c) {
        return Text(
          useProvider().toString(),
          textDirection: TextDirection.ltr,
        );
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [useProvider.overrideForSubtree(Provider.value(42))],
          child: child,
        ),
      );

      expect(find.text('42'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [useProvider.overrideForSubtree(Provider.value(21))],
          child: child,
        ),
      );

      expect(find.text('42'), findsNothing);
      expect(find.text('21'), findsOneWidget);
    });
  });
  group('Provider', () {
    testWidgets('can read and write state', (tester) async {
      // ProviderState<int> providerState;
      // int initialState;
      // final useProvider = Provider<int>((state) {
      //   providerState = state;
      //   initialState = state.value;
      //   return 42;
      // });

      // await tester.pumpWidget(
      //   ProviderScope(
      //     child: HookBuilder(builder: (c) {
      //       return Text(
      //         useProvider().toString(),
      //         textDirection: TextDirection.ltr,
      //       );
      //     }),
      //   ),
      // );

      // expect(find.text('42'), findsOneWidget);
      // expect(initialState, null);
      // expect(providerState.value, 42);

      // providerState.value = 21;

      // expect(providerState.value, 21);

      // await tester.pump();

      // expect(find.text('42'), findsNothing);
      // expect(find.text('21'), findsOneWidget);
    }, skip: true);

    testWidgets('mounted', (tester) async {
      ProviderState<int> providerState;
      bool mountedOnDispose;
      final useProvider = Provider<int>((state) {
        providerState = state;
        state.onDispose(() => mountedOnDispose = state.mounted);
        return 42;
      });

      await tester.pumpWidget(
        ProviderScope(
          child: HookBuilder(builder: (c) {
            return Text(
              useProvider().toString(),
              textDirection: TextDirection.ltr,
            );
          }),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      expect(providerState.mounted, isTrue);

      await tester.pumpWidget(Container());

      expect(mountedOnDispose, isTrue);
      expect(providerState.mounted, isFalse);
    });

    testWidgets('no onDispose does not crash', (tester) async {
      final useProvider = Provider<int>((state) => 42);

      await tester.pumpWidget(
        ProviderScope(
          child: HookBuilder(builder: (c) {
            return Text(
              useProvider().toString(),
              textDirection: TextDirection.ltr,
            );
          }),
        ),
      );

      expect(find.text('42'), findsOneWidget);

      await tester.pumpWidget(Container());
    });
    testWidgets("onDispose can't update the state", (tester) async {
      // final useProvider = Provider<int>((state) {
      //   state
      //     ..onDispose(() {
      //       state.value = 21;
      //     })
      //     ..onDispose(() {
      //       if (state.value != 42) {
      //         throw Error();
      //       }
      //     });
      //   return 42;
      // });

      // await tester.pumpWidget(
      //   ProviderScope(
      //     child: HookBuilder(builder: (c) {
      //       return Text(
      //         useProvider().toString(),
      //         textDirection: TextDirection.ltr,
      //       );
      //     }),
      //   ),
      // );

      // expect(find.text('42'), findsOneWidget);

      // await tester.pumpWidget(Container());

      // expect(tester.takeException(), isAssertionError);
    }, skip: true);
    testWidgets('onDispose can read state', (tester) async {
      // int onDisposeState;
      // final useProvider = Provider<int>((state) {
      //   state.onDispose(() => onDisposeState = state.value);
      //   return 42;
      // });

      // await tester.pumpWidget(
      //   ProviderScope(
      //     child: HookBuilder(builder: (c) {
      //       return Text(
      //         useProvider().toString(),
      //         textDirection: TextDirection.ltr,
      //       );
      //     }),
      //   ),
      // );

      // expect(find.text('42'), findsOneWidget);

      // await tester.pumpWidget(Container());

      // expect(onDisposeState, 42);
    }, skip: true);
    testWidgets("can't read state after dispose", (tester) async {
      // ProviderState<int> providerState;
      // final useProvider = Provider<int>((state) {
      //   providerState = state;
      //   return 42;
      // });

      // await tester.pumpWidget(
      //   ProviderScope(
      //     child: HookBuilder(builder: (c) {
      //       return Text(
      //         useProvider().toString(),
      //         textDirection: TextDirection.ltr,
      //       );
      //     }),
      //   ),
      // );

      // expect(find.text('42'), findsOneWidget);

      // await tester.pumpWidget(Container());

      // expect(() => providerState.value, throwsStateError);
    }, skip: true);
    testWidgets('onDispose calls all callbacks in order', (tester) async {
      final dispose1 = OnDisposeMock();

      final dispose2 = OnDisposeMock();
      final error2 = Error();
      when(dispose2()).thenThrow(error2);

      final dispose3 = OnDisposeMock();

      final useProvider = Provider<int>((state) {
        state..onDispose(dispose1)..onDispose(dispose2)..onDispose(dispose3);
        return 42;
      });

      await tester.pumpWidget(
        ProviderScope(
          child: HookBuilder(builder: (c) {
            return Text(
              useProvider().toString(),
              textDirection: TextDirection.ltr,
            );
          }),
        ),
      );

      expect(find.text('42'), findsOneWidget);
      verifyZeroInteractions(dispose1);
      verifyZeroInteractions(dispose2);
      verifyZeroInteractions(dispose3);

      await tester.pumpWidget(Container());

      verifyInOrder([
        dispose1(),
        dispose2(),
        dispose3(),
      ]);
      verifyNoMoreInteractions(dispose1);
      verifyNoMoreInteractions(dispose2);
      verifyNoMoreInteractions(dispose3);

      expect(tester.takeException(), error2);
    });

    testWidgets('expose value as is', (tester) async {
      var callCount = 0;
      final useProvider = Provider((state) {
        assert(state != null, '');
        callCount++;
        return 42;
      });

      await tester.pumpWidget(
        ProviderScope(
          child: HookBuilder(builder: (c) {
            return Text(
              useProvider().toString(),
              textDirection: TextDirection.ltr,
            );
          }),
        ),
      );

      expect(callCount, 1);
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('override updates rebuild dependents with new value',
        (tester) async {
      final useProvider = Provider.value(0);
      final child = HookBuilder(builder: (c) {
        return Text(
          useProvider().toString(),
          textDirection: TextDirection.ltr,
        );
      });

      var callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            useProvider.overrideForSubtree(
              Provider((state) {
                assert(state != null, '');
                callCount++;
                return 42;
              }),
            ),
          ],
          child: child,
        ),
      );

      expect(callCount, 1);
      expect(find.text('42'), findsOneWidget);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            useProvider.overrideForSubtree(
              Provider((state) {
                assert(state != null, '');
                callCount++;
                throw Error();
              }),
            ),
          ],
          child: child,
        ),
      );

      expect(callCount, 1);
      expect(find.text('42'), findsOneWidget);
    });
  });
}

class OnDisposeMock extends Mock {
  void call();
}
