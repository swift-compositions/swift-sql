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

// The Structured Queries `QueryBinding` is now stated in institute vocabulary (`Instant`,
// `QueryBinding.UUID`, `[Byte]`), so the map below is a pure container change: a `date` binding
// already IS the `Instant` ``SQL/Value`` carries, and the byte cases only re-domain `Byte` onto
// the engine-free `[UInt8]` payload. No Foundation is reached, transitively or otherwise.
internal import Byte_Primitives
public import PostgreSQL_Standard
internal import RFC_4122
public import SQL

extension SQL.Query {
    /// Lowers a Structured Queries DSL statement into an engine-free ``SQL/Query``.
    ///
    /// Runs `statement.query.prepare { "$\($0)" }` to get the `$1…$n`-positional SQL and its
    /// bindings, then maps each `QueryBinding` to a ``SQL/Value``. The v0 seam covers
    /// `text`/`int`/`double`/`bool`/`null`, `uuid` (via the UUID's 16 bytes), `date` (as an
    /// `Instant`), `blob`, and `jsonb`. Every other binding — `decimal`, the array cases, and
    /// `invalid` — throws ``SQL/Error/binding(_:)``.
    public init(_ statement: some Statement) throws(SQL.Error) {
        let prepared = statement.query.prepare { "$\($0)" }
        var values: [SQL.Value] = []
        values.reserveCapacity(prepared.bindings.count)
        for binding in prepared.bindings {
            values.append(try Self.value(from: binding))
        }
        self.init(sql: prepared.sql, bindings: values)
    }

    /// Maps a single `QueryBinding` to its ``SQL/Value`` counterpart.
    ///
    /// Total over every `QueryBinding` case except `invalid`, which carries a upstream binding
    /// failure and has no lawful value to map to.
    ///
    /// The eleven element-typed array bindings all land on the single recursive
    /// ``SQL/Value/array(_:)``: element type is the DSL's concern, and the seam needs only the
    /// element values and enough structure to quote and delimit them. `genericArray` therefore
    /// maps as faithfully as the typed arrays do, rather than degrading to NULL.
    static func value(from binding: QueryBinding) throws(SQL.Error) -> SQL.Value {
        switch binding {
        case .text(let text): return .text(text)
        case .int(let int): return .int64(int)
        case .double(let double): return .double(double)
        case .bool(let bool): return .bool(bool)
        case .null: return .null
        case .uuid(let uuid): return .uuid(try Self.identifier(from: uuid))
        case .date(let instant): return .timestamp(instant)
        case .blob(let bytes): return .blob(bytes.map(\.underlying))
        case .jsonb(let bytes): return .jsonb(bytes.map(\.underlying))
        // The digit string is carried verbatim. `numeric` admits far more digits than any
        // fixed-width decimal type, so parsing it here would narrow a value the engine accepts.
        case .decimal(let digits): return .decimal(digits)
        case .boolArray(let values): return .array(values.map { .bool($0) })
        case .stringArray(let values): return .array(values.map { .text($0) })
        case .intArray(let values): return .array(values.map { .int($0) })
        case .int16Array(let values): return .array(values.map { .int64(Int64($0)) })
        case .int32Array(let values): return .array(values.map { .int64(Int64($0)) })
        case .int64Array(let values): return .array(values.map { .int64($0) })
        case .floatArray(let values): return .array(values.map { .double(Double($0)) })
        case .doubleArray(let values): return .array(values.map { .double($0) })
        case .dateArray(let values): return .array(values.map { .timestamp($0) })
        case .uuidArray(let values):
            var identifiers: [SQL.Value] = []
            identifiers.reserveCapacity(values.count)
            for value in values { identifiers.append(.uuid(try Self.identifier(from: value))) }
            return .array(identifiers)
        case .genericArray(let values):
            var elements: [SQL.Value] = []
            elements.reserveCapacity(values.count)
            for value in values { elements.append(try Self.value(from: value)) }
            return .array(elements)
        case .invalid: throw SQL.Error.binding("binding is invalid")
        }
    }

    /// Re-domains a `QueryBinding.UUID`'s raw bytes onto ``RFC_4122/UUID``.
    ///
    /// The binding's byte count is deliberately unenforced upstream (a malformed binding must not
    /// trap a query), so the 16-byte width is checked here and reported as a binding failure.
    private static func identifier(
        from uuid: QueryBinding.UUID
    ) throws(SQL.Error) -> RFC_4122.UUID {
        do throws(RFC_4122.UUID.Error) {
            return try RFC_4122.UUID(uuid.bytes.map(\.underlying))
        } catch {
            throw SQL.Error.binding("uuid binding is not exactly 16 bytes")
        }
    }
}
