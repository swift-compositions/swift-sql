public import ISO_9075_Foundation

@resultBuilder
public enum SeedsBuilder {
    public static func buildArray(_ components: [[Seed]]) -> [Seed] {
        components.flatMap(\.self)
    }

    public static func buildBlock(_ components: [Seed]) -> [Seed] {
        components
    }

    public static func buildEither(first component: [Seed]) -> [Seed] {
        component
    }

    public static func buildEither(second component: [Seed]) -> [Seed] {
        component
    }

    public static func buildExpression<T: Table>(_ expression: T) -> [Seed] {
        [Seed(expression)]
    }

    public static func buildExpression<T: TableDraft>(_ expression: T) -> [Seed] {
        [Seed(draft: expression)]
    }

    public static func buildExpression<T: Table>(_ expression: [T]) -> [Seed] {
        expression.map(Seed.init)
    }

    public static func buildExpression<T: TableDraft>(_ expression: [T]) -> [Seed] {
        expression.map { Seed(draft: $0) }
    }

    public static func buildExpression<T: TableDraft>(_ expression: T) -> [Seed]
    where T.SourceTable: PrimaryKeyedTable {
        [Seed(draft: expression, primaryKeys: Set(T.SourceTable.columns.primaryKey._names))]
    }

    public static func buildExpression<T: TableDraft>(_ expression: [T]) -> [Seed]
    where T.SourceTable: PrimaryKeyedTable {
        let primaryKeys = Set(T.SourceTable.columns.primaryKey._names)
        return expression.map { Seed(draft: $0, primaryKeys: primaryKeys) }
    }

    public static func buildLimitedAvailability(_ component: [Seed]) -> [Seed] {
        component
    }

    public static func buildOptional(_ component: [Seed]?) -> [Seed] {
        component ?? []
    }

    public static func buildPartialBlock(first: [Seed]) -> [Seed] {
        first
    }

    public static func buildPartialBlock(accumulated: [Seed], next: [Seed]) -> [Seed] {
        accumulated + next
    }
}
