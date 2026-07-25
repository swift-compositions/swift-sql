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

    /// Maps a single `QueryBinding` to its ``SQL/Value`` counterpart, or throws for a case the v0
    /// seam does not carry.
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
        case .decimal: throw SQL.Error.binding("decimal unsupported by the v0 seam")
        case .boolArray: throw SQL.Error.binding("boolArray unsupported by the v0 seam")
        case .stringArray: throw SQL.Error.binding("stringArray unsupported by the v0 seam")
        case .intArray: throw SQL.Error.binding("intArray unsupported by the v0 seam")
        case .int16Array: throw SQL.Error.binding("int16Array unsupported by the v0 seam")
        case .int32Array: throw SQL.Error.binding("int32Array unsupported by the v0 seam")
        case .int64Array: throw SQL.Error.binding("int64Array unsupported by the v0 seam")
        case .floatArray: throw SQL.Error.binding("floatArray unsupported by the v0 seam")
        case .doubleArray: throw SQL.Error.binding("doubleArray unsupported by the v0 seam")
        case .uuidArray: throw SQL.Error.binding("uuidArray unsupported by the v0 seam")
        case .dateArray: throw SQL.Error.binding("dateArray unsupported by the v0 seam")
        case .genericArray: throw SQL.Error.binding("genericArray unsupported by the v0 seam")
        case .invalid: throw SQL.Error.binding("invalid unsupported by the v0 seam")
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
