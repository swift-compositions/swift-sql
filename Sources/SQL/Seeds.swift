public struct Seeds: Sequence {
    let seeds: [any Table]

    public init(@SeedsBuilder _ build: () -> [any Table]) {
        self.seeds = build()
    }

    public func makeIterator() -> Iterator {
        Iterator(seeds: seeds)
    }

    public struct Iterator: IteratorProtocol {
        var seeds: [any Table]

        public mutating func next() -> SQLQueryExpression<Void>? {
            guard let first = seeds.first else { return nil }

            let firstType = type(of: first)

            if let firstType = firstType as? any TableDraft.Type {
                func insertBatch<T: TableDraft>(_: T.Type) -> SQLQueryExpression<Void> {
                    let batch = Array(seeds.lazy.prefix { $0 is T }.compactMap { $0 as? T })
                    defer { seeds.removeFirst(batch.count) }
                    return SQLQueryExpression(T.SourceTable.insert { batch })
                }

                return insertBatch(firstType)
            } else {
                func insertBatch<T: Table>(_: T.Type) -> SQLQueryExpression<Void> {
                    let batch = Array(seeds.lazy.prefix { $0 is T }.compactMap { $0 as? T })
                    defer { seeds.removeFirst(batch.count) }
                    return SQLQueryExpression(T.insert { batch })
                }

                return insertBatch(firstType)
            }
        }
    }
}

@resultBuilder
public enum SeedsBuilder {
    public static func buildArray(_ components: [[any Table]]) -> [any Table] {
        components.flatMap(\.self)
    }

    public static func buildBlock(_ components: [any Table]) -> [any Table] {
        components
    }

    public static func buildEither(first component: [any Table]) -> [any Table] {
        component
    }

    public static func buildEither(second component: [any Table]) -> [any Table] {
        component
    }

    public static func buildExpression(_ expression: some Table) -> [any Table] {
        [expression]
    }

    public static func buildExpression(_ expression: [any Table]) -> [any Table] {
        expression
    }

    public static func buildLimitedAvailability(_ component: [any Table]) -> [any Table] {
        component
    }

    public static func buildOptional(_ component: [any Table]?) -> [any Table] {
        component ?? []
    }

    public static func buildPartialBlock(first: [any Table]) -> [any Table] {
        first
    }

    public static func buildPartialBlock(accumulated: [any Table], next: [any Table]) -> [any Table]
    {
        accumulated + next
    }
}
