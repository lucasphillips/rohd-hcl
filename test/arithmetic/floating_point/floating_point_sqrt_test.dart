// Copyright (C) 2025 Intel Corporation
// SPDX-License-Indentifier: BSD-3-Clause
//
// floating_point_sqrt.dart
// An abstract base class defining the API for floating-point square root.
//
// 2025 March 5
// Authors: James Farwell <james.c.farwell@intel.com>,
//Stephen Weeks <stephen.weeks@intel.com>,
//Curtis Anderson <curtis.anders@intel.com>

import 'dart:math';
import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/src/arithmetic/arithmetic.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() async {
    await Simulator.reset();
  });
  test('FP: square root with non-FP numbers', () {
    // building with 16-bit FP representation
    const exponentWidth = 8;
    const mantissaWidth = 23;

    final fv = FloatingPointValue(
        sign: LogicValue.zero,
        exponent: LogicValue.filled(exponentWidth, LogicValue.one),
        mantissa: LogicValue.filled(mantissaWidth, LogicValue.zero));

    final fp = FloatingPoint(
        exponentWidth: exponentWidth, mantissaWidth: mantissaWidth);
    fp.put(fv);

    for (final sqrtT in [
      FloatingPointSqrtSimple(fp),
    ]) {
      final testCases = [
        fv.clonePopulator().nan,
        fv.clonePopulator().positiveInfinity,
        fv.clonePopulator().positiveZero,
        fv.clonePopulator().positiveZero.negate(),
      ];

      for (final test in testCases) {
        final fv = test;

        final dSqrt = sqrt(fv.toDouble());
        final expSqrt = FloatingPointValue.populator(
                exponentWidth: exponentWidth, mantissaWidth: mantissaWidth)
            .ofDouble(dSqrt);
        final expSqrtd = expSqrt.toDouble();
        final Logic expError = Const(0);

        fp.put(fv);
        final fpOut = sqrtT.sqrtR;
        final eOut = sqrtT.error;
        expect(fpOut.floatingPointValue, equals(expSqrt),
            reason: '\t${fp.floatingPointValue} '
                '(${fp.floatingPointValue.toDouble()}) =\n'
                '\t${fpOut.floatingPointValue}'
                '(${fpOut.floatingPointValue.toDouble()}) actual\n'
                '\t$expSqrtd ($expSqrt) expected');

        expect(eOut.value, equals(expError.value),
            reason: 'error =\n'
                '\t${eOut.value} actual\n'
                '\t${expError.value} expected');
      }
    }
  });

  test('FP: square root with error flag high', () {
    const exponentWidth = 8;
    const mantissaWidth = 23;

    final fv = FloatingPointValue(
        sign: LogicValue.zero,
        exponent: LogicValue.filled(exponentWidth, LogicValue.one),
        mantissa: LogicValue.filled(mantissaWidth, LogicValue.zero));

    final fp = FloatingPoint(
        exponentWidth: exponentWidth, mantissaWidth: mantissaWidth);

    for (final sqrtDUT in [
      FloatingPointSqrtSimple(fp),
    ]) {
      final testCases = [
        fv.clonePopulator().positiveInfinity.negate(),
        fv.clonePopulator().one.negate(),
      ];

      for (final test in testCases) {
        final fv = test;
        final expError = Const(1);

        fp.put(fv);
        final eOut = sqrtDUT.error;

        expect(eOut.value, equals(expError.value),
            reason: 'error =\n'
                '\t${eOut.value} actual\n'
                '\t${expError.value} expected');
      }
    }
  });

  test('FP: targeted normalized sqrt', () {
    const exponentWidth = 8;
    const mantissaWidth = 23;
    const testDouble = 3.567;

    final fv1 = FloatingPointValue.populator(
            exponentWidth: exponentWidth, mantissaWidth: mantissaWidth)
        .ofDouble(testDouble);
    final fp = FloatingPoint(
        exponentWidth: exponentWidth, mantissaWidth: mantissaWidth);
    fp.put(fv1);
    final sqrtDUT = FloatingPointSqrtSimple(fp);
    final compResult = sqrtDUT.sqrtR;
    final compError = sqrtDUT.error;

    final expResult = FloatingPointValue.populator(
            exponentWidth: exponentWidth, mantissaWidth: mantissaWidth)
        .ofDouble(sqrt(testDouble));
    final expError = Const(0);
    expect(
        compResult.floatingPointValue.toDouble(), equals(expResult.toDouble()),
        reason: '\t${fp.floatingPointValue} '
            '(${fp.floatingPointValue.toDouble()}) =\n'
            '\t${compResult.floatingPointValue}'
            '(${compResult.floatingPointValue.toDouble()}) actual\n'
            '\t$expResult (${expResult.toDouble()}) expected');

    expect(compError.value, equals(expError.value),
        reason: 'error =\n'
            '\t${expError.value} actual\n'
            '\t${expError.value} expected');
  });
}
