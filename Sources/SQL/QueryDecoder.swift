public import Byte
public import RFC_4122
public import Time

public protocol QueryDecoder {
    mutating func decode(_ columnType: [Byte].Type) throws -> [Byte]?

    mutating func decode(_ columnType: Double.Type) throws -> Double?

    mutating func decode(_ columnType: Int64.Type) throws -> Int64?

    mutating func decode(_ columnType: UInt64.Type) throws -> UInt64?

    mutating func decode(_ columnType: String.Type) throws -> String?

    mutating func decode(_ columnType: Bool.Type) throws -> Bool?

    mutating func decode(_ columnType: Int.Type) throws -> Int?

    mutating func decode(_ columnType: Instant.Type) throws -> Instant?

    mutating func decode(_ columnType: RFC_4122.UUID.Type) throws -> RFC_4122.UUID?

    mutating func decode<T: QueryRepresentable>(_ columnType: T.Type) throws -> T.QueryOutput?

    mutating func decode<Column: _TableColumnExpression>(
        _ column: Column
    ) throws -> Column.Value.QueryOutput?
}

extension QueryDecoder {
    @inlinable
    @inline(__always)
    public mutating func decode<T: QueryRepresentable>(
        _ columnType: T.Type
    ) throws -> T.QueryOutput? {
        try T?(decoder: &self)?.queryOutput
    }

    @inlinable
    @inline(__always)
    public mutating func decodeColumns<each T: QueryRepresentable>(
        _ columnTypes: (repeat each T).Type
    ) throws -> (repeat (each T).QueryOutput) {
        try (repeat (each T)(decoder: &self).queryOutput)
    }

    @inlinable
    @inline(__always)
    public mutating func decode<Column: _TableColumnExpression>(
        _ column: Column
    ) throws -> Column.Value.QueryOutput? {
        try Column.Value?(decoder: &self)?.queryOutput
    }

    @_disfavoredOverload
    @inlinable
    @inline(__always)
    public mutating func decode<Column: _TableColumnExpression, Value>(
        _ column: Column
    ) throws -> Value.QueryOutput?
    where Column.Value == Value? {
        try decode(column) ?? nil
    }
}

public enum QueryDecodingError: Error {
    case missingRequiredColumn

    case typeMismatch(Any.Type)

    case other(any Error)
}
