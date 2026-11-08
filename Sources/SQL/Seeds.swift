public import ISO_9075_Foundation

public struct Seeds: Swift.Sequence {
    let seeds: [Seed]

    public init(@SeedsBuilder _ build: () -> [Seed]) {
        self.seeds = build()
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

extension Seeds {
    public func makeIterator() -> Iterator {
        Iterator(seeds: seeds[...])
    }
}
