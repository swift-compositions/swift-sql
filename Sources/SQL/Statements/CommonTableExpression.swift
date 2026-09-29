public import ISO_9075_Foundation

public struct With<Base: Statement>: Statement, Sendable {
    public typealias QueryValue = Base.QueryValue
    public typealias From = Never

    var ctes: [CommonTableExpressionClause]
    var statement: ISO_9075.Fragment
    var hasUpsertParsingAmbiguity: Bool

    @_disfavoredOverload
    public init(
        @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
        query statement: () -> Base
    ) {
        self.ctes = ctes()
        let statement = statement()
        self.statement = statement.query
        hasUpsertParsingAmbiguity = statement._hasUpsertParsingAmbiguity
    }

    public init<S: SelectStatement, each J: Table>(
        @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
        query statement: () -> S
    )
    where
        S.QueryValue == (),
        S.Joins == (repeat each J),
        Base == Select<(S.From, repeat each J), S.From, (repeat each J)>
    {
        self.ctes = ctes()
        let statement = statement()
        self.statement = statement.query
        hasUpsertParsingAmbiguity = statement._hasUpsertParsingAmbiguity
    }

    @_disfavoredOverload
    public init<S: SelectStatement>(
        @CommonTableExpressionBuilder _ ctes: () -> [CommonTableExpressionClause],
        query statement: () -> S
    )
    where
        S.QueryValue == (),
        S.Joins == (),
        Base == Select<S.From, S.From, ()>
    {
        self.ctes = ctes()
        let statement = statement()
        self.statement = statement.query
        hasUpsertParsingAmbiguity = statement._hasUpsertParsingAmbiguity
    }

    public var _hasUpsertParsingAmbiguity: Bool { hasUpsertParsingAmbiguity }

    public var query: ISO_9075.Fragment {
        guard !statement.isEmpty else { return "" }
        let cteFragments = ctes.compactMap(\.queryFragment.presence)
        guard !cteFragments.isEmpty else { return "" }
        var query: ISO_9075.Fragment = "WITH "
        query.append(
            "\(cteFragments.joined(separator: ", "))\(.newlineOrSpace)\(statement)"
        )
        return query
    }
}

extension With: PartialSelectStatement where Base: PartialSelectStatement {}


extension ISO_9075.Fragment {
    fileprivate var presence: Self? { isEmpty ? nil : self }
}

public struct CommonTableExpressionClause: QueryExpression, Sendable {
    public typealias QueryValue = ()
    let tableName: ISO_9075.Fragment
    let select: ISO_9075.Fragment
    let materialization: Materialization?

    init(tableName: ISO_9075.Fragment, select: ISO_9075.Fragment, materialization: Materialization? = nil) {
        self.tableName = tableName
        self.select = select
        self.materialization = materialization
    }

    public var queryFragment: ISO_9075.Fragment {
        guard !select.isEmpty else { return "" }
        return "\(tableName) AS \(materialization?.queryFragment ?? "")(\(.newline)\(select.indented())\(.newline))"
    }
}

extension CommonTableExpressionClause {
    public enum Materialization: Hashable, Sendable {
        case materialized
        case notMaterialized

        var queryFragment: ISO_9075.Fragment {
            switch self {
            case .materialized: "MATERIALIZED "
            case .notMaterialized: "NOT MATERIALIZED "
            }
        }
    }
}

extension PartialSelectStatement where QueryValue: Table {
    public func materialized(_ materialization: CommonTableExpressionClause.Materialization = .materialized) -> CommonTableExpressionClause {
        CommonTableExpressionClause(tableName: "\(QueryValue.self)", select: query, materialization: materialization)
    }
}

@resultBuilder
public enum CommonTableExpressionBuilder {
    public static func buildExpression<CTETable: Table>(
        _ expression: some PartialSelectStatement<CTETable>
    ) -> CommonTableExpressionClause {
        CommonTableExpressionClause(tableName: "\(CTETable.self)", select: expression.query)
    }

    public static func buildExpression(
        _ expression: CommonTableExpressionClause
    ) -> CommonTableExpressionClause {
        expression
    }

    public static func buildBlock(
        _ component: CommonTableExpressionClause
    ) -> [CommonTableExpressionClause] {
        [component]
    }

    public static func buildPartialBlock(
        first: CommonTableExpressionClause
    ) -> [CommonTableExpressionClause] {
        [first]
    }

    public static func buildPartialBlock(
        accumulated: [CommonTableExpressionClause],
        next: CommonTableExpressionClause
    ) -> [CommonTableExpressionClause] {
        accumulated + [next]
    }
}
