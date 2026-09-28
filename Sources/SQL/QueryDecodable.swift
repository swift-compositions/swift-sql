public import Byte
public import RFC_4122
public import Time

public protocol QueryDecodable: _OptionalPromotable, SendableMetatype {
    init(decoder: inout some QueryDecoder) throws(QueryDecodingError)
}

extension [Byte]: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let result = try decoder.decode([Byte].self)
        else { throw .missingRequiredColumn }
        self = result
    }
}

extension Double: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let result = try decoder.decode(Double.self)
        else { throw .missingRequiredColumn }
        self = result
    }
}

extension Int64: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let result = try decoder.decode(Int64.self)
        else { throw .missingRequiredColumn }
        self = result
    }
}

extension String: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let result = try decoder.decode(String.self)
        else { throw .missingRequiredColumn }
        self = result
    }
}

extension Bool: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        self = try Int(decoder: &decoder) != 0
    }
}

extension Time.Instant: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let result = try decoder.decode(Time.Instant.self)
        else { throw .missingRequiredColumn }
        self = result
    }
}

extension Float: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        try self.init(Double(decoder: &decoder))
    }
}

extension Int: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try Int64(decoder: &decoder)
        guard (Int64(Int.min)...Int64(Int.max)).contains(n) else { throw .overflow("\(n) as \(Self.self)") }
        self.init(n)
    }
}

extension Int8: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try Int64(decoder: &decoder)
        guard (Int64(Int8.min)...Int64(Int8.max)).contains(n) else { throw .overflow("\(n) as \(Self.self)") }
        self.init(n)
    }
}

extension Int16: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try Int64(decoder: &decoder)
        guard (Int64(Int16.min)...Int64(Int16.max)).contains(n) else { throw .overflow("\(n) as \(Self.self)") }
        self.init(n)
    }
}

extension Int32: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try Int64(decoder: &decoder)
        guard (Int64(Int32.min)...Int64(Int32.max)).contains(n) else { throw .overflow("\(n) as \(Self.self)") }
        self.init(n)
    }
}

extension UInt: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try UInt64(decoder: &decoder)
        guard let value = Self(exactly: n) else { throw .overflow("\(n) as \(Self.self)") }
        self = value
    }
}

extension UInt8: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try UInt64(decoder: &decoder)
        guard (UInt64(UInt8.min)...UInt64(UInt8.max)).contains(n) else { throw .overflow("\(n) as \(Self.self)") }
        self.init(n)
    }
}

extension UInt16: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try UInt64(decoder: &decoder)
        guard (UInt64(UInt16.min)...UInt64(UInt16.max)).contains(n) else { throw .overflow("\(n) as \(Self.self)") }
        self.init(n)
    }
}

extension UInt32: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let n = try UInt64(decoder: &decoder)
        guard (UInt64(UInt32.min)...UInt64(UInt32.max)).contains(n) else { throw .overflow("\(n) as \(Self.self)") }
        self.init(n)
    }
}

extension UInt64: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let result = try decoder.decode(UInt64.self)
        else { throw .missingRequiredColumn }
        self = result
    }
}

extension RFC_4122.UUID: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let result = try decoder.decode(RFC_4122.UUID.self)
        else { throw .missingRequiredColumn }
        self = result
    }
}

extension QueryDecodable where Self: LosslessStringConvertible {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let string = try String(decoder: &decoder)
        guard let losslessStringConvertible = Self(string)
        else {
            throw .dataCorrupted("\(string) as \(Self.self)")
        }
        self = losslessStringConvertible
    }
}

extension QueryDecodable where Self: RawRepresentable, RawValue: QueryDecodable {
    @inlinable
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        let rawValue = try RawValue(decoder: &decoder)
        guard let rawRepresentable = Self(rawValue: rawValue)
        else {
            throw .dataCorrupted("\(rawValue) as \(Self.self)")
        }
        self = rawRepresentable
    }
}
