// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import RFC_4122
public import Time_Primitive

extension SQL {
    /// A value bound to a statement parameter.
    ///
    /// This is the engine-free binding vocabulary of the ``SQL/Statement`` seam. It mirrors the
    /// subset of the Structured Queries `QueryBinding` cases the first consumers exercise, so a
    /// bridge from that DSL is a straight case-to-case map — but the seam itself carries no
    /// dependency on it. Identifiers and timestamps are expressed in institute L1/L2 vocabulary
    /// (``RFC_4122/UUID``, `Instant`), never Foundation types.
    public enum Value: Sendable, Hashable {
        case text(String)
        case int(Int)
        case int64(Int64)
        case double(Double)
        case bool(Bool)
        case uuid(RFC_4122.UUID)
        case timestamp(Instant)
        /// Raw bytes, bound to a `bytea`-style binary column.
        case blob([UInt8])
        /// UTF-8 JSON bytes, bound to a `jsonb`-style column.
        case jsonb([UInt8])
        /// An arbitrary-precision numeric, carried as its **exact digit string**.
        ///
        /// Never exponent notation, and never routed through a fixed-width decimal type:
        /// PostgreSQL `numeric` admits on the order of 131,072 integral digits, where
        /// `decimal128` admits 34. Narrowing here would silently truncate a value the
        /// database accepts, so the seam carries the digits verbatim and lets the engine
        /// parse them.
        case decimal(String)
        /// An array, bound to a PostgreSQL array-typed column.
        ///
        /// The DSL distinguishes eleven element-typed array bindings (`int16Array`,
        /// `int32Array`, `uuidArray`, and so on). This seam deliberately carries **one**
        /// recursive case instead of mirroring all eleven, because element type is the
        /// DSL's concern and not the execution seam's: a binding is transmitted in text
        /// format with an unspecified parameter type, so what an engine needs from this
        /// vocabulary is the element *values* and enough structure to quote and delimit
        /// them. Recursion also gives nested arrays and the DSL's heterogeneous
        /// `genericArray` a total mapping, rather than the silent NULL substitution that
        /// case currently receives.
        ///
        /// Element-type fidelity is not lost — it remains in the DSL binding the bridge
        /// maps from. It is simply not re-encoded here.
        indirect case array([SQL.Value])
        case null
    }
}
