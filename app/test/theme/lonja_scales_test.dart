import 'package:catchlaw/theme/lonja_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // The spine is published in token-tables.md. An off-spine value cannot be
  // scaled by glove mode, which multiplies named steps and has no idea what a
  // `13` was.
  const spine = <String, (double, double)>{
    's1': (LonjaSpace.s1, 4),
    's2': (LonjaSpace.s2, 8),
    's3': (LonjaSpace.s3, 12),
    's4': (LonjaSpace.s4, 16),
    's5': (LonjaSpace.s5, 24),
    's6': (LonjaSpace.s6, 32),
    's7': (LonjaSpace.s7, 48),
    's8': (LonjaSpace.s8, 64),
  };
  spine.forEach((String name, (double, double) pair) {
    test('LonjaSpace.$name is ${pair.$2} dp', () => expect(pair.$1, pair.$2));
  });

  // Four weights and no fifth. A 1.5 renders as a printing defect at 3x and
  // vanishes at 1x.
  const rules = <String, (double, double)>{
    'hair': (LonjaRules.hair, 0.5),
    'rule': (LonjaRules.rule, 1),
    'strong': (LonjaRules.strong, 2),
    'stamp': (LonjaRules.stamp, 3),
  };
  rules.forEach((String name, (double, double) pair) {
    test('LonjaRules.$name is ${pair.$2}', () => expect(pair.$1, pair.$2));
  });

  test('LonjaRules exposes exactly four weights', () {
    expect(<double>{
      LonjaRules.hair,
      LonjaRules.rule,
      LonjaRules.strong,
      LonjaRules.stamp,
    }, hasLength(4));
  });

  test('LonjaRadii.none is BorderRadius.zero', () {
    // Square corners are what the booklet has.
    expect(LonjaRadii.none, BorderRadius.zero);
  });

  test('LonjaRadii.hair is a 2 dp radius', () {
    // The ceiling. Check 4 of the gate fails anything above it.
    expect(LonjaRadii.hair, const BorderRadius.all(Radius.circular(2)));
  });

  const motion = <String, (Duration, Duration)>{
    'none': (LonjaMotion.none, Duration.zero),
    'quick': (LonjaMotion.quick, Duration(milliseconds: 90)),
    'page': (LonjaMotion.page, Duration(milliseconds: 140)),
  };
  motion.forEach((String name, (Duration, Duration) pair) {
    test('LonjaMotion.$name is ${pair.$2.inMilliseconds} ms', () => expect(pair.$1, pair.$2));
  });

  test('LonjaDensity.standard reports 48 dp targets with 4 dp separation', () {
    // SPEC.md §13's standard floor. T04 adds the glove row against ≥ 56 dp.
    expect(LonjaDensity.standard.tapMin, 48);
    expect(LonjaDensity.standard.tapGap, 4);
    expect(LonjaDensity.standard.rowHeight, 56);
    expect(LonjaDensity.standard.hitSlop, 0);
    expect(LonjaDensity.standard.gutter, LonjaSpace.s4);
  });

  test('LonjaDensity.standard sizes each target class at the mockup\'s ungloved figure', () {
    // The five classes §13 grows separately, at the size they are drawn before
    // glove mode touches them. They are here so the glove row is a comparison
    // against something rather than five numbers standing alone.
    expect(LonjaDensity.standard.actionHeight, 56);
    expect(LonjaDensity.standard.entryHeight, 60);
    expect(LonjaDensity.standard.navHeight, 62);
    expect(LonjaDensity.standard.tileWidth, 96);
    expect(LonjaDensity.standard.tileHeight, 96);
  });

  test('LonjaDensity == returns false when tapMin alone differs', () {
    // Density is a field inside LonjaTokens.==. If LonjaDensity.== were
    // identity, a glove switch would never repaint a painter.
    const a = LonjaDensity(
      tapMin: 48,
      tapGap: 4,
      rowHeight: 56,
      hitSlop: 0,
      gutter: 16,
      actionHeight: 56,
      entryHeight: 60,
      navHeight: 62,
      tileWidth: 96,
      tileHeight: 96,
    );
    const b = LonjaDensity(
      tapMin: 56,
      tapGap: 4,
      rowHeight: 56,
      hitSlop: 0,
      gutter: 16,
      actionHeight: 56,
      entryHeight: 60,
      navHeight: 62,
      tileWidth: 96,
      tileHeight: 96,
    );
    expect(a, isNot(b));
    expect(a, LonjaDensity.standard);
  });
}
