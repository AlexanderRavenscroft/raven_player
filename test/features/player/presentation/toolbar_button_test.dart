import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:raven_player/features/player/presentation/toolbar_button.dart';

void main() {
	testWidgets('exposes one labeled semantics button', (tester) async {
		final semantics = tester.ensureSemantics();

		await tester.pumpWidget(
			MaterialApp(
				home: Scaffold(
					body: ToolbarButton(
						icon: Icons.timer_outlined,
						isToggled: true,
						semanticLabel: 'Sleep timer',
						semanticHint: 'Stops playback automatically',
						semanticTapHint: 'toggle the timer',
						semanticLongPressHint: 'adjust its duration',
						semanticValue: '30 minutes',
						onPressed: () {},
						onLongPress: () {},
					),
				),
			),
		);

		final semanticsNode = find.semantics.byLabel('Sleep timer');
		expect(semanticsNode, findsOne);

		expect(
			semanticsNode.found.single,
			matchesSemantics(
				label: 'Sleep timer',
				hint: 'Stops playback automatically',
				value: '30 minutes',
				isButton: true,
				hasEnabledState: true,
				isEnabled: true,
				hasToggledState: true,
				isToggled: true,
				hasTapAction: true,
				hasLongPressAction: true,
				onTapHint: 'toggle the timer',
				onLongPressHint: 'adjust its duration',
			),
		);

		semantics.dispose();
	});

	testWidgets('can expose a plain tap action without redundant states', (
		tester,
	) async {
		final semantics = tester.ensureSemantics();

		await tester.pumpWidget(
			MaterialApp(
				home: Scaffold(
					body: ToolbarButton(
						icon: Icons.speed,
						hasToggleState: false,
						includeLongPressSemantics: false,
						semanticLabel: 'Playback speed',
						semanticTapHint: 'adjust the playback speed',
						onPressed: () {},
						onLongPress: () {},
					),
				),
			),
		);

		final semanticsNode = find.semantics.byLabel('Playback speed');
		expect(semanticsNode, findsOne);

		expect(
			semanticsNode.found.single,
			matchesSemantics(
				label: 'Playback speed',
				isButton: true,
				hasEnabledState: true,
				isEnabled: true,
				hasTapAction: true,
				onTapHint: 'adjust the playback speed',
			),
		);

		semantics.dispose();
	});
}
