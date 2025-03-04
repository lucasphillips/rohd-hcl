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
import 'package:meta/meta.dart';
import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/rohd_hcl.dart';

/// Abstract base class
abstract class FixedPointSqrtBase<FpType extends FloatingPoint> extends Module {
  /// Width of the input and output fields.
  final int numWidth;

  /// The value [a], named this way to allow for a local variable 'a'.
  @protected
  late final Logic a;

  /// getter for the computed [FloatingPoint] output.
  late final Logic sqrt = a.clone(name: 'sqrt')..gets(output('sqrt'));

  /// Square root a fixed point number [a], returning result in [sqrt].
  FixedPointSqrtBase(Logic a,
      {super.name = 'fixed_point_square_root', String? definitionName})
      : numWidth = a.width,
        super(
            definitionName:
                definitionName ?? 'FixedPointSquareRoot_E${a.width}') {
    this.a = (a.clone(name: 'a') as FpType)
      ..gets(addInput('a', a, width: a.width));

    addOutput('sqrt', width: numWidth);
  }
}

/// Implementation
class FixedPointSqrt extends FixedPointSqrtBase {
  /// Constructor
  FixedPointSqrt(super.a);
}
