public import Byte
public import ISO_9075_Foundation

extension QueryExpression where QueryValue: Collection {
    public func length() -> some QueryExpression<Int> {
        QueryFunction("length", self)
    }

}

extension QueryExpression where QueryValue: FloatingPoint {
    public func round(
        _ precision: (some QueryExpression<Int>)? = Int?.none
    ) -> some QueryExpression<QueryValue> {
        if let precision {
            return QueryFunction("round", self, precision)
        } else {
            return QueryFunction("round", self)
        }
    }
}

extension QueryExpression
where QueryValue: _OptionalPromotable, QueryValue._Optionalized.Wrapped: Numeric {
    public func abs() -> some QueryExpression<QueryValue> {
        QueryFunction("abs", self)
    }
}

extension QueryExpression where QueryValue: _OptionalPromotable {
    public func nullif<Other: QueryExpression>(
        _ other: Other
    ) -> SQLQueryExpression<QueryValue._Optionalized>
    where
        Other.QueryValue: _OptionalPromotable,
        Other.QueryValue._Optionalized == QueryValue._Optionalized
    {
        SQLQueryExpression(QueryFunction("nullif", self, other))
    }
}

extension QueryExpression where QueryValue: _OptionalProtocol {
    public static func ?? (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> CoalesceFunction<QueryValue.Wrapped> {
        CoalesceFunction([lhs.queryFragment, rhs.queryFragment])
    }

    public static func ?? (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> CoalesceFunction<QueryValue> {
        CoalesceFunction([lhs.queryFragment, rhs.queryFragment])
    }
}

extension QueryExpression where QueryValue: _OptionalPromotable<String?> {
    public func lower() -> some QueryExpression<QueryValue> {
        QueryFunction("lower", self)
    }
}

extension QueryExpression where QueryValue == String {
    public func ltrim(
        _ characters: (some QueryExpression<QueryValue>)? = QueryValue?.none
    ) -> some QueryExpression<QueryValue> {
        if let characters {
            return QueryFunction("ltrim", self, characters)
        } else {
            return QueryFunction("ltrim", self)
        }
    }

    public func octetLength() -> some QueryExpression<Int> {
        QueryFunction("octet_length", self)
    }
}

extension QueryExpression where QueryValue == String {
    public func replace(
        _ other: some QueryExpression<QueryValue>,
        _ replacement: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        QueryFunction("replace", self, other, replacement)
    }

    public func rtrim(
        _ characters: (some QueryExpression<QueryValue>)? = QueryValue?.none
    ) -> some QueryExpression<QueryValue> {
        if let characters {
            return QueryFunction("rtrim", self, characters)
        } else {
            return QueryFunction("rtrim", self)
        }
    }

    public func substr(
        _ offset: some QueryExpression<Int>,
        _ length: (some QueryExpression<Int>)? = Int?.none
    ) -> some QueryExpression<QueryValue> {
        if let length {
            return QueryFunction("substr", self, offset, length)
        } else {
            return QueryFunction("substr", self, offset)
        }
    }

    public func trim(
        _ characters: (some QueryExpression<QueryValue>)? = QueryValue?.none
    ) -> some QueryExpression<QueryValue> {
        if let characters {
            return QueryFunction("trim", self, characters)
        } else {
            return QueryFunction("trim", self)
        }
    }
}

extension QueryExpression where QueryValue: _OptionalPromotable<String?> {

    public func upper() -> some QueryExpression<QueryValue> {
        QueryFunction("upper", self)
    }
}

package struct QueryFunction<QueryValue>: QueryExpression {
    let name: ISO_9075.Fragment
    let arguments: [ISO_9075.Fragment]

    package init<each Argument: QueryExpression>(
        _ name: ISO_9075.Fragment,
        _ arguments: repeat each Argument
    ) {
        self.name = name
        self.arguments = Array(repeat each arguments)
    }

    public var queryFragment: ISO_9075.Fragment {
        "\(name)(\(arguments.joined(separator: ", ")))"
    }
}

public struct CoalesceFunction<QueryValue>: QueryExpression {
    private let arguments: [ISO_9075.Fragment]

    fileprivate init(_ arguments: [ISO_9075.Fragment]) {
        self.arguments = arguments
    }

    public var queryFragment: ISO_9075.Fragment {
        "coalesce(\(arguments.joined(separator: ", ")))"
    }

    public static func ?? <T: _OptionalProtocol<QueryValue>>(
        lhs: some QueryExpression<T>,
        rhs: Self
    ) -> CoalesceFunction<QueryValue> {
        Self([lhs.queryFragment] + rhs.arguments)
    }
}

extension CoalesceFunction where QueryValue: _OptionalProtocol {
    public static func ?? (
        lhs: some QueryExpression<QueryValue>,
        rhs: Self
    ) -> Self {
        Self([lhs.queryFragment] + rhs.arguments)
    }
}
