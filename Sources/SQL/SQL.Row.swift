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
    /// A decoded result row, addressed by column name or index.
    ///
    /// Conformers decode lazily: an accessor reads and converts the underlying engine column on
    /// demand, throwing ``SQL/Error/decoding(_:)`` on a type mismatch or missing column. A row is
    /// handed to a `fetchAll` / `fetchOne` decode closure and consumed synchronously; it never
    /// surfaces an engine type. Identifiers and timestamps are returned as institute vocabulary
    /// (``RFC_4122/UUID``, `Instant`), and `bytes` covers `blob`/`jsonb` columns.
    public protocol Row: Sendable {
        // MARK: By column name

        func string(_ column: String) throws(SQL.Error) -> String
        func int(_ column: String) throws(SQL.Error) -> Int
        func int64(_ column: String) throws(SQL.Error) -> Int64
        func double(_ column: String) throws(SQL.Error) -> Double
        func bool(_ column: String) throws(SQL.Error) -> Bool
        func uuid(_ column: String) throws(SQL.Error) -> RFC_4122.UUID
        func timestamp(_ column: String) throws(SQL.Error) -> Instant
        func bytes(_ column: String) throws(SQL.Error) -> [UInt8]

        func stringIfPresent(_ column: String) throws(SQL.Error) -> String?
        func intIfPresent(_ column: String) throws(SQL.Error) -> Int?
        func uuidIfPresent(_ column: String) throws(SQL.Error) -> RFC_4122.UUID?
        func timestampIfPresent(_ column: String) throws(SQL.Error) -> Instant?

        // MARK: By column index

        func string(at index: Int) throws(SQL.Error) -> String
        func int(at index: Int) throws(SQL.Error) -> Int
        func int64(at index: Int) throws(SQL.Error) -> Int64
        func double(at index: Int) throws(SQL.Error) -> Double
        func bool(at index: Int) throws(SQL.Error) -> Bool
        func uuid(at index: Int) throws(SQL.Error) -> RFC_4122.UUID
        func timestamp(at index: Int) throws(SQL.Error) -> Instant
        func bytes(at index: Int) throws(SQL.Error) -> [UInt8]
    }
}
