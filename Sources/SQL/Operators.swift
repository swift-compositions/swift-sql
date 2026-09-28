public import ISO_9075_Foundation

extension QueryExpression where QueryValue: QueryRepresentable {
    public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "=", rhs: other)
    }

    public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<>", rhs: other)
    }

    public func `is`<Other: QueryRepresentable>(
        _ other: some QueryExpression<Other>
    ) -> some QueryExpression<Bool>
    where QueryValue._Optionalized.Wrapped == Other._Optionalized.Wrapped {
        BinaryOperator(lhs: self, operator: "IS", rhs: other)
    }

    public func isNot<Other: QueryRepresentable>(
        _ other: some QueryExpression<QueryValue._Optionalized>
    ) -> some QueryExpression<Bool>
    where QueryValue._Optionalized.Wrapped == Other._Optionalized.Wrapped {
        BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
    }

    @available(*, unavailable, message: "Use 'eq' (or 'is') instead.")
    public static func == (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
    }

    @available(*, unavailable, message: "Use 'eq' (or 'is') instead.")
    public static func == (
        lhs: Self,
        rhs: some QueryExpression<QueryValue?>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
    }

    @available(*, unavailable, message: "Use 'eq' (or 'is') instead.")
    public static func == (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<Bool> where QueryValue: _OptionalProtocol {
        BinaryOperator(lhs: lhs, operator: "=", rhs: rhs)
    }

    @available(
        *,
        unavailable,
        message: "Use 'neq' or 'isNot' instead."
    )
    public static func != (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
    }

    @available(
        *,
        unavailable,
        message: "Use 'neq' or 'isNot' instead."
    )
    public static func != (
        lhs: Self,
        rhs: some QueryExpression<QueryValue?>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
    }

    @available(
        *,
        unavailable,
        message: "Use 'neq' or 'isNot' instead."
    )
    public static func != (
        lhs: Self,
        rhs: some QueryExpression<QueryValue.Wrapped>
    ) -> some QueryExpression<Bool> where QueryValue: _OptionalProtocol {
        BinaryOperator(lhs: lhs, operator: "<>", rhs: rhs)
    }

}

extension QueryExpression where QueryValue: QueryRepresentable & QueryExpression {
    @_documentation(visibility: private)
    public func `is`(
        _ other: _Null<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS", rhs: other)
    }

    @_documentation(visibility: private)
    public func isNot(
        _ other: _Null<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
    }
}

public struct _Null<Wrapped: QueryExpression>: QueryExpression {
    public typealias QueryValue = Wrapped?
    public var queryFragment: ISO_9075.Fragment {
        Wrapped?.none.queryFragment
    }
}

extension _Null: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {}
}

extension QueryExpression where QueryValue: QueryRepresentable & _OptionalProtocol {
    @_documentation(visibility: private)
    public func eq(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: "=", rhs: other)
    }

    @_documentation(visibility: private)
    public func neq(_ other: some QueryExpression<QueryValue.Wrapped>) -> some QueryExpression<Bool>
    {
        BinaryOperator(lhs: self, operator: "<>", rhs: other)
    }

    @_documentation(visibility: private)
    public func eq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "=", rhs: other)
    }

    @_documentation(visibility: private)
    public func neq(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<>", rhs: other)
    }

    @_documentation(visibility: private)
    public func `is`(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS", rhs: other)
    }

    @_documentation(visibility: private)
    public func isNot(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "IS NOT", rhs: other)
    }
}

extension QueryExpression where QueryValue: _OptionalPromotable {
    public static func < (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.lt(rhs)
    }

    public static func > (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.gt(rhs)
    }

    public static func <= (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.lte(rhs)
    }

    public static func >= (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        lhs.gte(rhs)
    }

    public func lt(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<", rhs: other)
    }

    public func gt(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: ">", rhs: other)
    }

    public func lte(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "<=", rhs: other)
    }

    public func gte(
        _ other: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: ">=", rhs: other)
    }
}

extension QueryExpression where QueryValue == Bool {
    public static func && (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        lhs.and(rhs)
    }

    public static func || (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        lhs.or(rhs)
    }

    public static prefix func ! (expression: Self) -> some QueryExpression<QueryValue> {
        expression.not()
    }

    public func and(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: self, operator: "AND", rhs: other)
    }

    public func or(_ other: some QueryExpression<QueryValue>) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: self, operator: "OR", rhs: other)
    }

    public func not() -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "NOT", base: self)
    }
}

extension SQLQueryExpression<Bool> {
    public mutating func toggle() {
        self = Self(not())
    }
}

extension QueryExpression where QueryValue: Numeric {
    public static func + (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "+", rhs: rhs)
    }

    public static func - (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "-", rhs: rhs)
    }

    public static func * (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "*", rhs: rhs)
    }

    public static func / (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "/", rhs: rhs)
    }

    public static prefix func - (expression: Self) -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "-", base: expression, separator: "")
    }

    public static prefix func + (expression: Self) -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "+", base: expression, separator: "")
    }
}

@_documentation(visibility: private)
public prefix func - <QueryValue: Numeric>(
    expression: any QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
    func open(_ expression: some QueryExpression<QueryValue>) -> SQLQueryExpression<QueryValue> {
        SQLQueryExpression(UnaryOperator(operator: "-", base: expression, separator: ""))
    }
    return open(expression)
}

@_documentation(visibility: private)
public prefix func + <QueryValue: Numeric>(
    expression: any QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
    func open(_ expression: some QueryExpression<QueryValue>) -> SQLQueryExpression<QueryValue> {
        SQLQueryExpression(UnaryOperator(operator: "+", base: expression, separator: ""))
    }
    return open(expression)
}

extension SQLQueryExpression where QueryValue: Numeric {
    public static func += (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs + rhs)
    }

    public static func -= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs - rhs)
    }

    public static func *= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs * rhs)
    }

    public static func /= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs / rhs)
    }

    public mutating func negate() {
        self = Self(-self)
    }
}

extension QueryExpression where QueryValue: BinaryInteger {
    public static func % (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue?> {
        BinaryOperator(lhs: lhs, operator: "%", rhs: rhs)
    }

    public static func & (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "&", rhs: rhs)
    }

    public static func | (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "|", rhs: rhs)
    }

    public static func << (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "<<", rhs: rhs)
    }

    public static func >> (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: ">>", rhs: rhs)
    }

    public static prefix func ~ (expression: Self) -> some QueryExpression<QueryValue> {
        UnaryOperator(operator: "~", base: expression, separator: "")
    }
}

@_documentation(visibility: private)
public prefix func ~ <QueryValue: BinaryInteger>(
    expression: any QueryExpression<QueryValue>
) -> some QueryExpression<QueryValue> {
    func open(_ expression: some QueryExpression<QueryValue>) -> SQLQueryExpression<QueryValue> {
        SQLQueryExpression(UnaryOperator(operator: "~", base: expression, separator: ""))
    }
    return open(expression)
}

extension SQLQueryExpression where QueryValue: BinaryInteger {
    public static func &= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs & rhs)
    }

    public static func |= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs | rhs)
    }

    public static func <<= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs << rhs)
    }

    public static func >>= (lhs: inout Self, rhs: some QueryExpression<QueryValue>) {
        lhs = Self(lhs >> rhs)
    }
}

extension QueryExpression where QueryValue == String {
    public static func + (
        lhs: Self,
        rhs: some QueryExpression<QueryValue>
    ) -> some QueryExpression<QueryValue> {
        BinaryOperator(lhs: lhs, operator: "||", rhs: rhs)
    }

    public func glob(_ pattern: some StringProtocol) -> some QueryExpression<Bool> {
        BinaryOperator(lhs: self, operator: "GLOB", rhs: "\(pattern)")
    }

    public func like(
        _ pattern: some StringProtocol,
        escape: Character? = nil
    ) -> some QueryExpression<Bool> {
        LikeOperator(string: self, pattern: "\(pattern)", escape: escape)
    }
}

extension SQLQueryExpression<String> {
    public static func += (
        lhs: inout Self,
        rhs: some QueryExpression<QueryValue>
    ) {
        lhs = Self(lhs + rhs)
    }

    public mutating func append(_ other: some QueryExpression<QueryValue>) {
        self += other
    }

    public mutating func append(contentsOf other: some QueryExpression<QueryValue>) {
        self += other
    }
}

extension QueryExpression where QueryValue: QueryExpression {
    public func `in`<S: Sequence>(_ expression: S) -> some QueryExpression<Bool>
    where S.Element: QueryExpression<QueryValue> {
        BinaryOperator(lhs: self, operator: "IN", rhs: S.Expression(elements: expression))
    }

    public func notIn<S: Sequence>(_ expression: S) -> some QueryExpression<Bool>
    where S.Element: QueryExpression<QueryValue> {
        BinaryOperator(lhs: self, operator: "NOT IN", rhs: S.Expression(elements: expression))
    }

    public func `in`(_ query: some Statement<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(
            lhs: self,
            operator: "IN",
            rhs: SQLQueryExpression("\(query.query)", as: Void.self)
        )
    }

    public func notIn(_ query: some Statement<QueryValue>) -> some QueryExpression<Bool> {
        BinaryOperator(
            lhs: self,
            operator: "NOT IN",
            rhs: SQLQueryExpression("\(query.query)", as: Void.self)
        )
    }

    public func between(
        _ lowerBound: some QueryExpression<QueryValue>,
        and upperBound: some QueryExpression<QueryValue>
    ) -> some QueryExpression<Bool> {
        SQLQueryExpression("\(self) BETWEEN \(lowerBound) AND \(upperBound)")
    }
}

extension Statement where QueryValue: QueryBindable {
}

extension PartialSelectStatement {
    public func exists() -> some QueryExpression<Bool> {
        SQLQueryExpression("EXISTS \(self.queryFragment)")
    }
}

extension Table {
    public static func exists() -> some QueryExpression<Bool> {
        all.exists()
    }
}

private struct UnaryOperator<QueryValue>: QueryExpression {
    let `operator`: ISO_9075.Fragment
    let base: ISO_9075.Fragment
    let separator: ISO_9075.Fragment

    init(operator: ISO_9075.Fragment, base: some QueryExpression, separator: ISO_9075.Fragment = " ") {
        self.operator = `operator`
        self.base = base.queryFragment
        self.separator = separator
    }

    var queryFragment: ISO_9075.Fragment {
        "\(`operator`)\(separator)(\(base))"
    }
}

struct BinaryOperator<QueryValue>: QueryExpression {
    let lhs: ISO_9075.Fragment
    let `operator`: ISO_9075.Fragment
    let rhs: ISO_9075.Fragment

    init(
        lhs: some QueryExpression,
        operator: ISO_9075.Fragment,
        rhs: some QueryExpression
    ) {
        self.lhs = lhs.queryFragment
        self.operator = `operator`
        self.rhs = rhs.queryFragment
    }

    var queryFragment: ISO_9075.Fragment {
        "(\(lhs)) \(`operator`) (\(rhs))"
    }
}

private struct LikeOperator<
    LHS: QueryExpression<String>,
    RHS: QueryExpression<String>
>: QueryExpression {
    typealias QueryValue = Bool

    let string: LHS
    let pattern: RHS
    let escape: Character?

    var queryFragment: ISO_9075.Fragment {
        var query: ISO_9075.Fragment = "(\(string.queryFragment) LIKE \(pattern.queryFragment)"
        if let escape {
            query.append(" ESCAPE \(bind: String(escape))")
        }
        query.append(")")
        return query
    }
}

extension Sequence where Element: QueryExpression, Element.QueryValue: QueryExpression {
    fileprivate typealias Expression = _SequenceExpression<Self>
}

private struct _SequenceExpression<S: Sequence>: QueryExpression
where S.Element: QueryExpression, S.Element.QueryValue: QueryExpression {
    typealias QueryValue = S
    let queryFragment: ISO_9075.Fragment
    init(elements: S) {
        queryFragment = elements.map { "(\($0.queryFragment))" }.joined(separator: ", ")
    }
}
