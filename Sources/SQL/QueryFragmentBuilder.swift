public import ISO_9075_Foundation

@resultBuilder
public enum QueryFragmentBuilder<Clause> {
    public static func buildBlock(_ component: [ISO_9075.Fragment]) -> [ISO_9075.Fragment] {
        component
    }

    public static func buildEither(first component: [ISO_9075.Fragment]) -> [ISO_9075.Fragment] {
        component
    }

    public static func buildEither(second component: [ISO_9075.Fragment]) -> [ISO_9075.Fragment] {
        component
    }

    public static func buildOptional(_ component: [ISO_9075.Fragment]?) -> [ISO_9075.Fragment] {
        component ?? []
    }
}

extension QueryFragmentBuilder<Bool> {
    public static func buildArray(_ components: [[ISO_9075.Fragment]]) -> [ISO_9075.Fragment] {
        components.map { $0.joined(separator: " AND ") }
    }

    public static func buildExpression(
        _ expression: some QueryExpression<Bool>
    ) -> [ISO_9075.Fragment] {
        [expression.queryFragment]
    }

    public static func buildExpression(
        _ expression: some QueryExpression<some _OptionalPromotable<Bool?>>
    ) -> [ISO_9075.Fragment] {
        [expression.queryFragment]
    }

    public static func buildExpression(_ expression: Never?) -> [ISO_9075.Fragment] {
        []
    }
}

extension QueryFragmentBuilder<Int> {
    public static func buildExpression(
        _ expression: some QueryExpression<Int>
    ) -> [ISO_9075.Fragment] {
        [expression.queryFragment]
    }

    public static func buildExpression(_ expression: Never?) -> [ISO_9075.Fragment] {
        []
    }
}

extension QueryFragmentBuilder<()> {
    public static func buildExpression<each C: QueryExpression>(
        _ expression: (repeat each C)
    ) -> [ISO_9075.Fragment] {
        Array(repeat each expression)
    }
}

extension QueryFragmentBuilder<any Statement> {
    public static func buildExpression(
        _ expression: some Statement
    ) -> [ISO_9075.Fragment] {
        [expression.query]
    }

    public static func buildBlock(
        _ first: [ISO_9075.Fragment],
        _ rest: [ISO_9075.Fragment]...
    ) -> [ISO_9075.Fragment] {
        first + rest.flatMap(\.self)
    }
}
