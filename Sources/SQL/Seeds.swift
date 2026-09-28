public import ISO_9075_Foundation

public struct Seeds: Sequence {
    let seeds: [Seed]

    public init(@SeedsBuilder _ build: () -> [Seed]) {
        self.seeds = build()
    }

    public func makeIterator() -> Iterator {
        Iterator(seeds: seeds[...])
    }

    public struct Iterator: IteratorProtocol {
        var seeds: ArraySlice<Seed>

        public mutating func next() -> SQLQueryExpression<Void>? {
            guard let first = seeds.first else { return nil }
            let batch = seeds.prefix { $0.table == first.table }
            seeds.removeFirst(batch.count)
            return first.insert(batch.map(\.row))
        }
    }
}

public struct Seed {
    let table: ObjectIdentifier
    let row: [ISO_9075.Fragment]
    let insert: ([[ISO_9075.Fragment]]) -> SQLQueryExpression<Void>

    init<T: Table>(_ row: T) {
        self.table = ObjectIdentifier(T.self)
        self.row = T.TableColumns.writableColumns.map { $0.render(row) }
        self.insert = { rows in
            SQLQueryExpression(T._insert(columnNames: T.TableColumns.writableColumns.map(\.name), rows: rows))
        }
    }

    init<T: TableDraft>(draft row: T) {
        self.table = ObjectIdentifier(T.self)
        self.row = T.TableColumns.writableColumns.map { $0.render(row) }
        self.insert = { rows in
            SQLQueryExpression(
                T.SourceTable._insert(columnNames: T.TableColumns.writableColumns.map(\.name), rows: rows)
            )
        }
    }
}

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
        expression.map(Seed.init(draft:))
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
