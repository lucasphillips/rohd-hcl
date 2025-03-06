// Copyright (C) 2025 Intel Corporation
// SPDX-License-Indentifier: BSD-3-Clause
//
// fixed_sqrt_test.dart
// Tests for fixed-point square root.
//
// 2025 March 5
// Authors: James Farwell <james.c.farwell@intel.com>,
// Stephen Weeks <stephen.weeks@intel.com>,
// Curtis Anderson <curtis.anders@intel.com>

import 'dart:math';
import 'package:rohd/rohd.dart';
import 'package:rohd_hcl/src/arithmetic/arithmetic.dart';
import 'package:test/test.dart';

void main() {
  tearDown(() async {
    await Simulator.reset();
  });
  test('sqrt(1)', () async {
    final fixed = FixedPoint(signed: false, m: 1, n: 31);
    final dut = FixedPointSqrt(fixed);
    await dut.build();
    fixed.put(FixedPointValue.ofDouble(1,
        signed: fixed.signed, m: fixed.m, n: fixed.n));
    final fpvResult = dut.sqrtF.fixedPointValue;
    final fpvExpected = FixedPointValue.ofDouble(1,
        signed: fixed.signed, m: fixed.m, n: fixed.n);
    expect(fpvResult, fpvExpected);
  });

  test('sqrt(1.5)', () async {
    final fixed = FixedPoint(signed: false, m: 1, n: 31);
    final dut = FixedPointSqrt(fixed);
    await dut.build();
    fixed.put(FixedPointValue.ofDouble(1.5,
        signed: fixed.signed, m: fixed.m, n: fixed.n));
    final fpvResult = dut.sqrtF.fixedPointValue;
    final fpvExpected = FixedPointValue.ofDouble(sqrt(1.5),
        signed: fixed.signed, m: fixed.m, n: fixed.n);
    expect(fpvResult, fpvExpected);
  });
  test('sqrt(1.7)', () async {
    final fixed = FixedPoint(signed: false, m: 1, n: 31);
    final dut = FixedPointSqrt(fixed);
    await dut.build();
    fixed.put(FixedPointValue.ofDouble(1.7,
        signed: fixed.signed, m: fixed.m, n: fixed.n));
    final fpvResult = dut.sqrtF.fixedPointValue;
    final fpvExpected = FixedPointValue.ofDouble(sqrt(1.7),
        signed: fixed.signed, m: fixed.m, n: fixed.n);
    expect(fpvResult, fpvExpected);
  });
  test('sqrt(1.005)', () async {
    final fixed = FixedPoint(signed: false, m: 1, n: 31);
    final dut = FixedPointSqrt(fixed);
    await dut.build();
    fixed.put(FixedPointValue.ofDouble(1.005,
        signed: fixed.signed, m: fixed.m, n: fixed.n));
    final fpvResult = dut.sqrtF.fixedPointValue;
    final fpvExpected = FixedPointValue.ofDouble(sqrt(1.005),
        signed: fixed.signed, m: fixed.m, n: fixed.n);
    expect(fpvResult, fpvExpected);
  });
}
