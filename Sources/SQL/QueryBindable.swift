public import Byte
public import ISO_9075_Foundation
public import RFC_4122
public import Time

public protocol QueryBindable: QueryRepresentable, QueryExpression where QueryValue: QueryBindable {
    associatedtype QueryValue = Self

    var queryBinding: ISO_9075.Value { get }
}

extension QueryBindable {
    public var queryFragment: ISO_9075.Fragment { "\(queryBinding)" }
}

extension [Byte]: QueryBindable, QueryExpression {
    public var queryBinding: ISO_9075.Value { .blob(self) }
}

extension Bool: QueryBindable {
    public var queryBinding: ISO_9075.Value { .bool(self) }
}

extension Double: QueryBindable {
    public var queryBinding: ISO_9075.Value { .double(self) }
}

extension Float: QueryBindable {
    public var queryBinding: ISO_9075.Value { .double(Double(self)) }
}

extension Int: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(Int64(self)) }
}

extension Int8: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(Int64(self)) }
}

extension Int16: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(Int64(self)) }
}

extension Int32: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(Int64(self)) }
}

extension Int64: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(self) }
}

extension String: QueryBindable {
    public var queryBinding: ISO_9075.Value { .text(self) }
}

extension UInt8: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(Int64(self)) }
}

extension UInt16: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(Int64(self)) }
}

extension UInt32: QueryBindable {
    public var queryBinding: ISO_9075.Value { .int(Int64(self)) }
}

extension UInt64: QueryBindable {
    public var queryBinding: ISO_9075.Value {
        Int64(exactly: self).map(ISO_9075.Value.int) ?? .invalid(ISO_9075.Value.Failure("\(self) exceeds the largest SQL integer"))
    }
}

extension Time.Instant: QueryBindable {
    public var queryBinding: ISO_9075.Value { .timestamp(self) }
}

extension RFC_4122.UUID: QueryBindable {
    public var queryBinding: ISO_9075.Value { .uuid(self) }
}

extension QueryBindable where Self: LosslessStringConvertible {
    public var queryBinding: ISO_9075.Value { description.queryBinding }
}

extension QueryBindable where Self: RawRepresentable, RawValue: QueryBindable {
    public var queryBinding: ISO_9075.Value { rawValue.queryBinding }
}
