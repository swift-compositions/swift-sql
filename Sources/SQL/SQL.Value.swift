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
        case null
    }
}
