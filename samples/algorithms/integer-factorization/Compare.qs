// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Samples.IntegerFactorization {
    open Microsoft.Quantum.Arithmetic;
    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Measurement;

    /// # Summary
    /// Performs greater-than-or-equals comparison to a constant.
    ///
    /// # Description
    /// Toggles output qubit `target` if and only if input register `y`
    /// is greater than or equal to `c`.
    ///
    /// # Input
    /// ## c
    /// Constant value for comparison.
    /// ## y
    /// Quantum register to compare against.
    /// ## target
    /// Target qubit for comparison result.
    operation CompareGreaterThanOrEqualConstant(c : BigInt, y : LittleEndian, target : Qubit)
    : Unit is Adj+Ctl {
        CompareGreaterThanOrEqualConstantImpl(c, y, target);
    }

    /// # Summary
    /// Internal operation used in the implementation of GreaterThanOrEqualConstant.
    internal operation CompareGreaterThanOrEqualConstantImpl(c : BigInt, x : LittleEndian, target : Qubit)
    : Unit is Adj+Ctl {
        let bitWidth = Length(x!);

        if c == 0L {
            X(target);
        } elif c >= PowL(2L, bitwidth) {
            // do nothing
        } elif c == PowL(2L, bitwidth - 1) {
            ApplyLowTCNOT(Tail(x!), target);
        } else {
            // normalize constant
            let l = NTrailingZeroes(c);

            let cNormalized = c >>> l;
            let xNormalized = x![l...];
            let bitwidthNormalized = Length(xNormalized);
            let gates = Rest(BigIntAsBoolArraySized(cNormalized, bitwidthNormalized));

            use qs = Qubit[bitwidthNormalized - 1];
            let cs1 = [Head(xNormalized)] + Most(qs);
            let cs2 = Rest(xNormalized);

            within {
                for (c1, c2, t, gateType) in Zipped4(cs1, cs2, qs, gates) {
                    (gateType ? ApplyAnd | ApplyOr)(c1, c2, t);
                }
            } apply {
                ApplyLowTCNOT(Tail(qs), target);
            }
        }
    }

    /// # Summary
    /// Internal operation used in the implementation of GreaterThanOrEqualConstant.
    internal operation ApplyOr(control1 : Qubit, control2 : Qubit, target : Qubit) : Unit is Adj+Ctl {
        within {
            ApplyToEachA(X, [control1, control2]);
        } apply {
            ApplyAnd(control1, control2, target);
            X(target);
        }
    }
}
