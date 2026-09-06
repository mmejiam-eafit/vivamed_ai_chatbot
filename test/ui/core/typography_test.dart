import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:radiologist_helper/ui/core/design_tokens.dart';

/// Contract tests for the type stack — see design_language.md §4.
///
/// These load the real `.ttf` files rather than the test placeholder font,
/// because the failures they guard against are all silent: a misregistered
/// family falls back to a system face, and an OpenType feature that is never
/// requested is simply inert. Neither shows up as a test failure anywhere else.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    for (final family in <String, List<String>>{
      AppTypography.fontFamilyDisplay: <String>[
        'IBMPlexSans-Regular',
        'IBMPlexSans-SemiBold',
        'IBMPlexSans-Bold',
      ],
      AppTypography.fontFamilyBody: <String>[
        'Inter-Regular',
        'Inter-SemiBold',
        'Inter-Bold',
      ],
      AppTypography.fontFamilyMono: <String>[
        'IBMPlexMono-Regular',
        'IBMPlexMono-SemiBold',
        'IBMPlexMono-Bold',
      ],
    }.entries) {
      final loader = FontLoader(family.key);
      for (final file in family.value) {
        loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
      }
      await loader.load();
    }
  });

  double widthOf(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  group('font registration', () {
    test('every family declared in AppTypography renders real glyphs', () {
      for (final family in <String>[
        AppTypography.fontFamilyDisplay,
        AppTypography.fontFamilyBody,
        AppTypography.fontFamilyMono,
      ]) {
        final style = TextStyle(fontFamily: family, fontSize: 16);
        expect(widthOf('Radiologist', style), greaterThan(0),
            reason: '$family produced no advance width');
      }
    });

    test('weights are distinct — SemiBold and Bold are not the same face', () {
      const base = TextStyle(
        fontFamily: AppTypography.fontFamilyBody,
        fontSize: 16,
      );
      final regular = widthOf('Findings', base);
      final semiBold =
          widthOf('Findings', base.copyWith(fontWeight: FontWeight.w600));
      final bold =
          widthOf('Findings', base.copyWith(fontWeight: FontWeight.w700));

      expect(regular, isNot(closeTo(semiBold, 0.01)));
      expect(semiBold, isNot(closeTo(bold, 0.01)));
    });
  });

  group('tabular figures', () {
    // Inter's digits are proportional by default: `1` is far narrower than
    // `0`. Without `tnum`, numbers in a worklist column shift as values
    // change. This is the test that proves the feature is actually active.
    test('AppTypography.numeric aligns digits to a common advance', () {
      expect(
        widthOf('111111', AppTypography.numeric),
        closeTo(widthOf('000000', AppTypography.numeric), 0.01),
      );
    });

    test('body prose deliberately keeps proportional figures', () {
      expect(
        widthOf('111111', AppTypography.bodyMd),
        isNot(closeTo(widthOf('000000', AppTypography.bodyMd), 1.0)),
        reason: 'bodyMd must not carry tnum — tabular figures read wrong '
            'mid-sentence. If this fails, tabularFeatures leaked into prose.',
      );
    });

    test('mono is inherently tabular', () {
      expect(
        widthOf('111111', AppTypography.mono),
        closeTo(widthOf('000000', AppTypography.mono), 0.01),
      );
    });
  });

  group('perceptual hierarchy', () {
    // Inter's x-height (0.546 em) exceeds IBM Plex Sans's (0.516 em), so a
    // heading set at the same nominal size as body text would be out-measured
    // by it. The display scale has to sit above the body scale to compensate.
    test('the smallest heading still out-measures the largest body text', () {
      final headingX = widthOf('x', AppTypography.headingSm);
      final bodyX = widthOf('x', AppTypography.bodyLg);
      expect(headingX, greaterThan(bodyX),
          reason: 'headingSm (${AppTypography.headingSm.fontSize}) no longer '
              'dominates bodyLg (${AppTypography.bodyLg.fontSize})');
    });

    test('display and body scales are each monotonic', () {
      final display = <TextStyle>[
        AppTypography.headingSm,
        AppTypography.headingMd,
        AppTypography.headingLg,
        AppTypography.displaySm,
        AppTypography.displayMd,
        AppTypography.displayLg,
      ];
      final body = <TextStyle>[
        AppTypography.caption,
        AppTypography.bodySm,
        AppTypography.bodyMd,
        AppTypography.bodyLg,
      ];
      for (final scale in <List<TextStyle>>[display, body]) {
        for (var i = 1; i < scale.length; i++) {
          expect(scale[i].fontSize!, greaterThan(scale[i - 1].fontSize!));
        }
      }
    });

    test('clinical text never falls below the 12px floor', () {
      // `caption` is the documented exception: non-clinical metadata only.
      for (final style in <TextStyle>[
        AppTypography.bodySm,
        AppTypography.bodyMd,
        AppTypography.bodyLg,
        AppTypography.mono,
        AppTypography.numeric,
      ]) {
        expect(style.fontSize!, greaterThanOrEqualTo(12));
      }
    });
  });

  group('feature declarations', () {
    test('tabularFeatures requests both tnum and Inter\'s ss02', () {
      expect(
        AppTypography.tabularFeatures.map((ui.FontFeature f) => f.feature),
        containsAll(<String>['tnum', 'ss02']),
      );
    });

    test('mono requests a slashed zero', () {
      expect(
        AppTypography.monoFeatures.map((ui.FontFeature f) => f.feature),
        contains('zero'),
      );
    });
  });
}
