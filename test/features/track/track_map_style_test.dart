import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:step_counter/features/track/data/track_map_style.dart';
import 'package:step_counter/features/track/presentation/widgets/track_map_style_button.dart';

void main() {
  group('TrackMapStyle', () {
    test('every style has a valid tile url and a native zoom below the cap', () {
      for (final style in TrackMapStyle.values) {
        expect(style.urlTemplate, contains('{z}'), reason: style.name);
        expect(style.urlTemplate, contains('{x}'), reason: style.name);
        expect(style.urlTemplate, contains('{y}'), reason: style.name);
        // Map zoom is capped at 22; closer views scale tiles beyond this.
        expect(style.maxNativeZoom, inInclusiveRange(15, 19), reason: style.name);
        expect(style.attribution, isNotEmpty);
      }
    });

    test('satellite uses Esri z/y/x ordering', () {
      expect(
        TrackMapStyle.satellite.urlTemplate.endsWith('{z}/{y}/{x}'),
        isTrue,
      );
    });
  });

  testWidgets('style button opens the picker and reports the choice', (
    tester,
  ) async {
    TrackMapStyle current = TrackMapStyle.standard;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: Align(
              alignment: Alignment.topRight,
              child: TrackMapStyleButton(
                style: current,
                onChanged: (style) => setState(() => current = style),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('map_style_button')));
    await tester.pumpAndSettle();

    expect(find.text('Map type'), findsOneWidget);
    expect(find.text('Standard'), findsOneWidget);
    expect(find.text('Satellite'), findsOneWidget);
    expect(find.text('Terrain'), findsOneWidget);

    await tester.tap(find.byKey(const Key('map_style_satellite')));
    await tester.pumpAndSettle();

    expect(current, TrackMapStyle.satellite);
    expect(find.text('Map type'), findsNothing);
  });
}
