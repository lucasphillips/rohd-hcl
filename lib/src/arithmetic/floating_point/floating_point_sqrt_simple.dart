// Copyright (C) 2025 Intel Corporation
// SPDX-License-Indentifier: BSD-3-Clause
//
// floating_point_sqrt.dart
// An abstract base class defining the API for floating-point square root.
//
// 2025 March 4
// Authors: James Farwell <james.c.farwell@intel.com>,
//Stephen Weeks <stephen.weeks@intel.com>,
//Curtis Anderson <curtis.anders@intel.com>

import 'dart:math';

import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/rohd_hcl.dart';

/// An square root module for FloatingPoint values
class FloatingPointSqrtSimple<FpType extends FloatingPoint>
    extends FloatingPointSqrt<FpType> {
  /// Square root one floating point number [a], returning results
  /// [sqrtR] and [error]
  FloatingPointSqrtSimple(super.a,
      {super.clk,
      super.reset,
      super.enable,
      super.name = 'floatingpoint_square_root_simple'})
      : super(
            definitionName: 'FloatingPointSquareRootSimple_'
                'E${a.exponent.width}M${a.mantissa.width}') {
    final outputSqrt = FloatingPoint(
        exponentWidth: exponentWidth,
        mantissaWidth: mantissaWidth,
        name: 'sqrtR');
    output('sqrtR') <= outputSqrt;

    // check to see if we do sqrt at all or just return a
    final isInf = a.isAnInfinity.named('isInf');
    final isNaN = a.isNaN.named('isNan');
    final isZero = a.isAZero.named('isZero');
    final enableSqrt = ~((isInf | isNaN | isZero) | a.sign).named('enableSqrt');

    // debias the exponent
    final deBiasAmt = (1 << a.exponent.width - 1) - 1;

    // deBias math
    final deBiasExp = a.exponent - deBiasAmt;

    // shift exponent
    final shiftedExp =
        [Const(0), deBiasExp.slice(a.exponent.width - 1, 1)].swizzle();

    // check if exponent was odd
    final isExpOdd = deBiasExp[0];

    // use fixed sqrt unit
    final aFixed = FixedPoint(signed: false, m: 3, n: a.mantissa.width);
    aFixed <= [Const(1, width: 3), a.mantissa.getRange(0)].swizzle();

    // mux to choose if we do square root or not
    final fixedCalcSqrt = aFixed.clone()
      ..gets(mux(enableSqrt, FixedPointSqrt(aFixed).sqrtF, aFixed)
          .named('sqrtMux'));

    // if we have an odd value for the mantissa we calculate
    // mantissa * sqrt(2)
    final sqrtMult = FixedPointValue.ofDouble(sqrt(2),
        signed: false, m: a.mantissa.width + 1, n: a.mantissa.width);

    // need to expand our values because when we multiply two n-bit numbers
    // we get an (n*2) - 1 number back.
    // We have a special kind of value where our n will stay constant but
    // our m will grow to n (general formula is [2*(n+m) - 1] - n)
    final expandedCalc =
        FixedPoint(signed: false, m: a.mantissa.width + 3, n: a.mantissa.width);
    expandedCalc <=
        [Const(0, fill: true, width: a.mantissa.width), fixedCalcSqrt]
            .swizzle();

    // calculate our adjusted odd mantissa
    final fixedM = FixedPoint.of(
            Const(sqrtMult.value, width: expandedCalc.width),
            signed: false,
            m: a.mantissa.width + 3,
            n: a.mantissa.width) *
        expandedCalc;

    // select which mantissa we need to use
    final fixedSqrt = expandedCalc.clone()
      ..gets(mux(isExpOdd, fixedM, expandedCalc).named('mantissa select'));

    // convert back to floating point representation
    final fpSqrt = FixedToFloat(fixedSqrt,
        exponentWidth: a.exponent.width, mantissaWidth: a.mantissa.width);

    // final calculation results
    Combinational([
      errorSig < Const(0),
      If.block([
        Iff(isInf & ~a.sign, [
          outputSqrt < outputSqrt.inf(),
        ]),
        ElseIf(isInf & a.sign, [
          outputSqrt < outputSqrt.inf(negative: true),
          errorSig < Const(1),
        ]),
        ElseIf(isNaN, [
          outputSqrt < outputSqrt.nan,
        ]),
        ElseIf(isZero, [
          outputSqrt.sign < a.sign,
          outputSqrt.exponent < a.exponent,
          outputSqrt.mantissa < a.mantissa,
        ]),
        ElseIf(a.sign, [
          outputSqrt.sign < a.sign,
          outputSqrt.exponent < a.exponent,
          outputSqrt.mantissa < a.mantissa,
          errorSig < Const(1),
        ]),
        Else([
          outputSqrt.sign < a.sign,
          outputSqrt.exponent < (shiftedExp + deBiasAmt),
          outputSqrt.mantissa < fpSqrt.float.mantissa,
        ])
      ])
    ]);
  }
}
