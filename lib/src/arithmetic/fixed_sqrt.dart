// Copyright (C) 2025 Intel Corporation
// SPDX-License-Indentifier: BSD-3-Clause
//
// fixed_point_sqrt.dart
// An abstract base class defining the API for floating-point square root.
//
// 2025 March 3
// Authors: James Farwell <james.c.farwell@intel.com>, Stephen
// Weeks <stephen.weeks@intel.com>

/// An abstract API for fixed point square root.
library;

import 'package:meta/meta.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/rohd_hcl.dart';

/// Abstract base class
abstract class FixedPointSqrtBase extends Module {
  /// Width of the input and output fields.
  final int numWidth;

  /// The value [a], named this way to allow for a local variable 'a'.
  @protected
  late final FixedPoint a;

  /// getter for the computed output.
  late final FixedPoint sqrtF = a.clone(name: 'sqrtF')..gets(output('sqrtF'));

  /// Square root a fixed point number [a], returning result in [sqrtF].
  FixedPointSqrtBase(FixedPoint a,
      {super.name = 'fixed_point_square_root', String? definitionName})
      : numWidth = a.width,
        super(
            definitionName:
                definitionName ?? 'FixedPointSquareRoot${a.width}') {
    this.a = a.clone(name: 'a')..gets(addInput('a', a, width: a.width));

    addOutput('sqrtF', width: numWidth);
  }
}

/// Implementation
/// Algorithm explained here;
/// https://www.reddit.com/r/math/comments/tc7lur/computing_square_roots_in_binary_by_hand_is/?rdt=33100
class FixedPointSqrt extends FixedPointSqrtBase {
  /// Constructor
  FixedPointSqrt(super.a) {
    Logic solution = a.clone(name: 'solution');
    Logic remainder = a.clone(name: 'remainder');
    Logic subtractionValue = a.clone(name: 'subValue');

    // loop once through input value
    for (var i = 0; i < numWidth >> 1; i++) {
      // append bits from num, two at a time
      remainder = [
        remainder.slice(numWidth - 3, 0),
        a.slice(a.width - 1 - (i * 2), 2)
      ].swizzle();
      subtractionValue =
          [solution.slice(numWidth - 3, 0), Const(1, width: 2)].swizzle();
      solution = [solution.slice(numWidth - 2, 0), Const(1)].swizzle();

      final solBit0 = Logic();
      Combinational([
        If.block([
          Iff(subtractionValue.lte(remainder), [
            remainder < remainder - subtractionValue,
            solBit0 < Const(1),
          ])
        ])
      ]);
      solution <= [solution.slice(numWidth - 1, 1), solBit0].swizzle();
    }

    // loop again to finish remainder
    for (var i = 0; i < numWidth >> 1; i++) {
      // don't try to append bits from num, they are done
      remainder =
          [remainder.slice(numWidth - 3, 0), Const(0, width: 2)].swizzle();
      subtractionValue =
          [solution.slice(numWidth - 3, 0), Const(1, width: 2)].swizzle();
      solution = [solution.slice(numWidth - 2, 0), Const(1)].swizzle();

      final solBit0 = Logic();
      Combinational([
        If.block([
          Iff(subtractionValue.lte(remainder), [
            remainder < remainder - subtractionValue,
            solBit0 < Const(1),
          ])
        ])
      ]);
      solution <= [solution.slice(numWidth - 1, 1), solBit0].swizzle();
    }
    // assign solution to sqrt
    sqrtF <= solution;
  }
}
