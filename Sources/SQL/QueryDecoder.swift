public import Byte
public import RFC_4122
public import Time

public protocol QueryDecoder {
    mutating func decode(_ columnType: [Byte].Type) throws(QueryDecodingError) -> [Byte]?

    mutating func decode(_ columnType: Double.Type) throws(QueryDecodingError) -> Double?

    mutating func decode(_ columnType: Int64.Type) throws(QueryDecodingError) -> Int64?

    mutating func decode(_ columnType: UInt64.Type) throws(QueryDecodingError) -> UInt64?

    mutating func decode(_ columnType: String.Type) throws(QueryDecodingError) -> String?

    mutating func decode(_ columnType: Bool.Type) throws(QueryDecodingError) -> Bool?

    mutating func decode(_ columnType: Int.Type) throws(QueryDecodingError) -> Int?

    mutating func decode(_ columnType: Time.Instant.Type) throws(QueryDecodingError) -> Time.Instant?

    mutating func decode(_ columnType: RFC_4122.UUID.Type) throws(QueryDecodingError) -> RFC_4122.UUID?

    mutating func decode<T: QueryRepresentable>(_ columnType: T.Type) throws(QueryDecodingError) -> T.QueryOutput?

    mutating func decode<Column: _TableColumnExpression>(
        _ column: Column
    ) throws(QueryDecodingError) -> Column.Value.QueryOutput?
}

extension QueryDecoder {
    @inlinable
    @inline(__always)
    public mutating func decode<T: QueryRepresentable>(
        _ columnType: T.Type
    ) throws(QueryDecodingError) -> T.QueryOutput? {
        try T?(decoder: &self)?.queryOutput
    }

    @inlinable
    @inline(__always)
    public mutating func decodeColumns<each T: QueryRepresentable>(
        _ columnTypes: (repeat each T).Type
    ) throws(QueryDecodingError) -> (repeat (each T).QueryOutput) {
        try (repeat (each T)(decoder: &self).queryOutput)
    }

    @inlinable
    @inline(__always)
    public mutating func decode<Column: _TableColumnExpression>(
        _ column: Column
    ) throws(QueryDecodingError) -> Column.Value.QueryOutput? {
        try Column.Value?(decoder: &self)?.queryOutput
    }

    @_disfavoredOverload
    @inlinable
    @inline(__always)
    public mutating func decode<Column: _TableColumnExpression, Value>(
        _ column: Column
    ) throws(QueryDecodingError) -> Value.QueryOutput?
    where Column.Value == Value? {
        try decode(column) ?? nil
    }
}

public enum QueryDecodingError: Error, Hashable, Sendable {
    case missingRequiredColumn
    case typeMismatch(expected: String)
    case dataCorrupted(String)
    case overflow(String)
}
