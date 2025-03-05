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

import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/rohd_hcl.dart';

/// An square root module for FloatingPoint values
class FloatingPointSqrtSimple<FpType extends FloatingPoint>
    extends FloatingPointSqrt<FpType> {
  /// Square root one floating point number [a], returning results
  /// [sqrt] and [error]
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
        name: 'sqrt');
    output('sqrt') <= outputSqrt;

    final internalError = Logic(name: 'error');
    output('error') <= internalError;

    // check to see if we do sqrt at all or just return a
    final isInf = a.isAnInfinity.named('isInf');
    final isNaN = a.isNaN.named('isNan');
    final isZero = a.isAZero.named('isZero');
    final enableSqrt = ~((isInf | isNaN | isZero) | a.sign).named('enableSqrt');

    // use fixed sqrt unit
    final aFixed = FixedPoint(signed: false, m: 1, n: a.mantissa.width);
    aFixed <= [Const(1), a.mantissa].swizzle();

    // mux to choose if we do square root or not
    final fixedSqrt = aFixed.clone()
      ..gets(mux(enableSqrt, FixedPointSqrt(aFixed).sqrt, aFixed)
          .named('sqrtMux'));

    // convert back to floating point representation
    final fpSqrt = FixedToFloat(fixedSqrt,
        exponentWidth: a.exponent.width, mantissaWidth: a.mantissa.width);

    // final calculation results
    Combinational([
      error < Const(0),
      If.block([
        Iff(isInf & ~a.sign, [
          outputSqrt < outputSqrt.inf(),
        ]),
        ElseIf(isInf & a.sign, [
          outputSqrt < outputSqrt.inf(negative: true),
          error < Const(1),
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
          error < Const(1),
        ]),
        Else([
          outputSqrt.sign < a.sign,
          outputSqrt.exponent < fpSqrt.float.exponent,
          outputSqrt.mantissa < fpSqrt.float.mantissa,
        ])
      ])
    ]);
  }
}
