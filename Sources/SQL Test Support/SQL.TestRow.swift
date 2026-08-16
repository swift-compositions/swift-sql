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
public import SQL
public import Time_Primitive

extension SQL {
    /// A concrete ``SQL/Row`` over an in-memory `[String: SQL.Value]` column map plus an ordered
    /// column list (keys, sorted, for stable by-index access). Accessors convert from the stored
    /// ``SQL/Value`` case, raising ``SQL/Error/decoding(_:)`` on a mismatch or missing column.
    public struct TestRow: SQL.Row {
        public let columns: [String: SQL.Value]
        public let order: [String]

        public init(_ columns: [String: SQL.Value]) {
            self.columns = columns
            self.order = columns.keys.sorted()
        }
    }
}

extension SQL.TestRow {
    private func value(_ column: String) throws(SQL.Error) -> SQL.Value {
        guard let value = columns[column] else {
            throw SQL.Error.decoding("no such column \"\(column)\"")
        }
        return value
    }

    private func value(at index: Int) throws(SQL.Error) -> SQL.Value {
        guard index >= 0, index < order.count else {
            throw SQL.Error.decoding("column index \(index) out of range")
        }
        return columns[order[index]] ?? .null
    }

    // MARK: By column name

    public func string(_ column: String) throws(SQL.Error) -> String {
        try Self.asString(value(column))
    }
    public func int(_ column: String) throws(SQL.Error) -> Int { try Self.asInt(value(column)) }
    public func int64(_ column: String) throws(SQL.Error) -> Int64 {
        try Self.asInt64(value(column))
    }
    public func double(_ column: String) throws(SQL.Error) -> Double {
        try Self.asDouble(value(column))
    }
    public func bool(_ column: String) throws(SQL.Error) -> Bool { try Self.asBool(value(column)) }
    public func uuid(_ column: String) throws(SQL.Error) -> RFC_4122.UUID {
        try Self.asUUID(value(column))
    }
    public func timestamp(_ column: String) throws(SQL.Error) -> Instant {
        try Self.asTimestamp(value(column))
    }
    public func bytes(_ column: String) throws(SQL.Error) -> [UInt8] {
        try Self.asBytes(value(column))
    }

    public func stringIfPresent(_ column: String) throws(SQL.Error) -> String? {
        try Self.ifPresent(value(column), Self.asString)
    }
    public func intIfPresent(_ column: String) throws(SQL.Error) -> Int? {
        try Self.ifPresent(value(column), Self.asInt)
    }
    public func int64IfPresent(_ column: String) throws(SQL.Error) -> Int64? {
        try Self.ifPresent(value(column), Self.asInt64)
    }
    public func doubleIfPresent(_ column: String) throws(SQL.Error) -> Double? {
        try Self.ifPresent(value(column), Self.asDouble)
    }
    public func boolIfPresent(_ column: String) throws(SQL.Error) -> Bool? {
        try Self.ifPresent(value(column), Self.asBool)
    }
    public func uuidIfPresent(_ column: String) throws(SQL.Error) -> RFC_4122.UUID? {
        try Self.ifPresent(value(column), Self.asUUID)
    }
    public func timestampIfPresent(_ column: String) throws(SQL.Error) -> Instant? {
        try Self.ifPresent(value(column), Self.asTimestamp)
    }
    public func bytesIfPresent(_ column: String) throws(SQL.Error) -> [UInt8]? {
        try Self.ifPresent(value(column), Self.asBytes)
    }

    // MARK: By column index

    public func string(at index: Int) throws(SQL.Error) -> String {
        try Self.asString(value(at: index))
    }
    public func int(at index: Int) throws(SQL.Error) -> Int { try Self.asInt(value(at: index)) }
    public func int64(at index: Int) throws(SQL.Error) -> Int64 {
        try Self.asInt64(value(at: index))
    }
    public func double(at index: Int) throws(SQL.Error) -> Double {
        try Self.asDouble(value(at: index))
    }
    public func bool(at index: Int) throws(SQL.Error) -> Bool { try Self.asBool(value(at: index)) }
    public func uuid(at index: Int) throws(SQL.Error) -> RFC_4122.UUID {
        try Self.asUUID(value(at: index))
    }
    public func timestamp(at index: Int) throws(SQL.Error) -> Instant {
        try Self.asTimestamp(value(at: index))
    }
    public func bytes(at index: Int) throws(SQL.Error) -> [UInt8] {
        try Self.asBytes(value(at: index))
    }

    // MARK: By column index (optional)
    //
    // An out-of-range index throws ``SQL/Error/decoding(_:)`` (matching the by-name "no such
    // column" behaviour — an absent column is an error, not a silent `nil`); an in-range
    // ``SQL/Value/null`` decodes to `nil`.

    public func stringIfPresent(at index: Int) throws(SQL.Error) -> String? {
        try Self.ifPresent(value(at: index), Self.asString)
    }
    public func intIfPresent(at index: Int) throws(SQL.Error) -> Int? {
        try Self.ifPresent(value(at: index), Self.asInt)
    }
    public func int64IfPresent(at index: Int) throws(SQL.Error) -> Int64? {
        try Self.ifPresent(value(at: index), Self.asInt64)
    }
    public func doubleIfPresent(at index: Int) throws(SQL.Error) -> Double? {
        try Self.ifPresent(value(at: index), Self.asDouble)
    }
    public func boolIfPresent(at index: Int) throws(SQL.Error) -> Bool? {
        try Self.ifPresent(value(at: index), Self.asBool)
    }
    public func uuidIfPresent(at index: Int) throws(SQL.Error) -> RFC_4122.UUID? {
        try Self.ifPresent(value(at: index), Self.asUUID)
    }
    public func timestampIfPresent(at index: Int) throws(SQL.Error) -> Instant? {
        try Self.ifPresent(value(at: index), Self.asTimestamp)
    }
    public func bytesIfPresent(at index: Int) throws(SQL.Error) -> [UInt8]? {
        try Self.ifPresent(value(at: index), Self.asBytes)
    }
}

extension SQL.TestRow {
    private static func ifPresent<Value>(
        _ value: SQL.Value,
        _ convert: (SQL.Value) throws(SQL.Error) -> Value
    ) throws(SQL.Error) -> Value? {
        if case .null = value { return nil }
        return try convert(value)
    }

    private static func asString(_ value: SQL.Value) throws(SQL.Error) -> String {
        guard case .text(let text) = value else {
            throw SQL.Error.decoding("expected text, got \(value)")
        }
        return text
    }

    private static func asInt(_ value: SQL.Value) throws(SQL.Error) -> Int {
        switch value {
        case .int(let int): return int

        case .int64(let int):
            guard let narrowed = Int(exactly: int) else {
                throw SQL.Error.decoding("int64 \(int) does not fit Int")
            }
            return narrowed

        default: throw SQL.Error.decoding("expected int, got \(value)")
        }
    }

    private static func asInt64(_ value: SQL.Value) throws(SQL.Error) -> Int64 {
        switch value {
        case .int64(let int): return int
        case .int(let int): return Int64(int)
        default: throw SQL.Error.decoding("expected int64, got \(value)")
        }
    }

    private static func asDouble(_ value: SQL.Value) throws(SQL.Error) -> Double {
        guard case .double(let double) = value else {
            throw SQL.Error.decoding("expected double, got \(value)")
        }
        return double
    }

    private static func asBool(_ value: SQL.Value) throws(SQL.Error) -> Bool {
        guard case .bool(let bool) = value else {
            throw SQL.Error.decoding("expected bool, got \(value)")
        }
        return bool
    }

    private static func asUUID(_ value: SQL.Value) throws(SQL.Error) -> RFC_4122.UUID {
        guard case .uuid(let uuid) = value else {
            throw SQL.Error.decoding("expected uuid, got \(value)")
        }
        return uuid
    }

    private static func asTimestamp(_ value: SQL.Value) throws(SQL.Error) -> Instant {
        guard case .timestamp(let instant) = value else {
            throw SQL.Error.decoding("expected timestamp, got \(value)")
        }
        return instant
    }

    private static func asBytes(_ value: SQL.Value) throws(SQL.Error) -> [UInt8] {
        switch value {
        case .blob(let bytes), .jsonb(let bytes): return bytes
        default: throw SQL.Error.decoding("expected bytes, got \(value)")
        }
    }
}
