public import Byte
public import ISO_9075_Foundation
public import RFC_4122
public import Time

public protocol QueryRepresentable<QueryOutput>: QueryDecodable {
    associatedtype QueryOutput

    init(queryOutput: QueryOutput)

    var queryOutput: QueryOutput { get }

    static func queryFragment(decoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment

    static func _queryFragment(jsonEncoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment

    static func _queryFragment(jsonDecoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment

    static var _valuesColumns: [ValuesElement.Column] { get }

    static var _valuesFieldOffsets: [Int] { get }

    static func _valuesColumnIndex(of keyPath: AnyKeyPath) -> Int?


}

extension QueryRepresentable {
    public static func _queryFragment(jsonEncoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
        queryFragment
    }

    public static func _queryFragment(jsonDecoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
        queryFragment
    }

    @inlinable
    @inline(__always)
    public static func queryFragment(decoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
        queryFragment
    }


}

extension QueryRepresentable where Self: QueryDecodable, Self == QueryOutput {
    @inlinable
    @inline(__always)
    public init(queryOutput: QueryOutput) {
        self = queryOutput
    }

    @inlinable
    @inline(__always)
    public var queryOutput: QueryOutput {
        self
    }
}

extension [Byte]: QueryRepresentable {}

extension Bool: QueryRepresentable {
    public static func _queryFragment(jsonEncoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
        "\(ISO_9075.Keyword.jsonBooleanOpen)\(queryFragment)\(ISO_9075.Keyword.jsonBooleanClose)"
    }
}

extension Double: QueryRepresentable {}

extension Float: QueryRepresentable {}

extension Int: QueryRepresentable {}

extension Int8: QueryRepresentable {}

extension Int16: QueryRepresentable {}

extension Int32: QueryRepresentable {}

extension Int64: QueryRepresentable {}

extension String: QueryRepresentable {}

extension UInt8: QueryRepresentable {}

extension UInt16: QueryRepresentable {}

extension UInt32: QueryRepresentable {}

extension UInt64: QueryRepresentable {}

extension Instant: QueryRepresentable {}

extension RFC_4122.UUID: QueryRepresentable {}
