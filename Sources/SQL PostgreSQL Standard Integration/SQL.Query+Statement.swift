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

// This target is the sanctioned Foundation opt-in: the Structured Queries `QueryBinding` carries
// Foundation `UUID` / `Date` / `Data` payloads, which the map below lowers into institute
// vocabulary (`RFC_4122.UUID`, `Instant`, `[UInt8]`). Foundation is reached only transitively
// through the DSL — no `import Foundation`, and no new Foundation-typed public surface.
internal import Foundation
public import PostgreSQL_Standard
internal import RFC_4122
public import SQL
internal import Time_Primitive

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
        case .uuid(let uuid): return .uuid(RFC_4122.UUID(bytes: uuid.uuid))
        case .date(let date): return .timestamp(Self.instant(from: date))
        case .blob(let bytes): return .blob(bytes)
        case .jsonb(let data): return .jsonb(Array(data))
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

    /// Converts a Foundation `Date` to an `Instant`, truncating to whole seconds and rounding the
    /// sub-second remainder to the nearest nanosecond (clamped to a valid fraction).
    private static func instant(from date: Date) -> Instant {
        let interval = date.timeIntervalSince1970
        let seconds = Int64(interval.rounded(.down))
        var nanos = Int32(((interval - Double(seconds)) * 1_000_000_000).rounded())
        if nanos < 0 { nanos = 0 }
        if nanos > 999_999_999 { nanos = 999_999_999 }
        do throws(Instant.Error) {
            return try Instant(secondsSinceUnixEpoch: seconds, nanosecondFraction: nanos)
        } catch {
            // Unreachable in practice (nanos is clamped to the valid range above);
            // preserves the original optional-try fallback to whole seconds.
            return Instant(secondsSinceUnixEpoch: seconds)
        }
    }
}
