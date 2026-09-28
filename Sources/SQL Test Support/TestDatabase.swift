public import ISO_9075_Call_Level_Interface

public actor TestDatabase: ISO_9075.Database {
    public private(set) var executed: [ISO_9075.Rendering] = []
    public private(set) var scopes: [Scope] = []
    private var results: [[Row]] = []

    public init() {}
}

extension TestDatabase {
    public enum Scope: Hashable, Sendable {
        case read
        case write
        case rollback
    }

    public struct Dialect: ISO_9075.Dialect {
        public func placeholder(_ offset: Int) -> String { "$\(offset)" }
    }

    public struct Row: ISO_9075.Row {
        public let columns: [String]
        public let values: [ISO_9075.Value]

        public init(_ pairs: KeyValuePairs<String, ISO_9075.Value>) {
            self.columns = pairs.map(\.key)
            self.values = pairs.map(\.value)
        }

        public func value(at index: Int) throws(ISO_9075.Error) -> ISO_9075.Value {
            guard values.indices.contains(index) else { throw .decoding("no column at \(index)") }
            return values[index]
        }
    }

    public func script(_ rows: [Row]) {
        results.append(rows)
    }

    public func read<Value: Sendable>(
        _ body: @Sendable (any ISO_9075.Connection) async throws(ISO_9075.Error) -> Value
    ) async throws(ISO_9075.Error) -> Value {
        scopes.append(.read)
        return try await body(Connection(database: self))
    }

    public func write<Value: Sendable>(
        _ body: @Sendable (any ISO_9075.Connection) async throws(ISO_9075.Error) -> Value
    ) async throws(ISO_9075.Error) -> Value {
        scopes.append(.write)
        return try await body(Connection(database: self))
    }

    public func withRollback<Value: Sendable>(
        _ body: @Sendable (any ISO_9075.Connection) async throws(ISO_9075.Error) -> Value
    ) async throws(ISO_9075.Error) -> Value {
        scopes.append(.rollback)
        return try await body(Connection(database: self))
    }

    fileprivate func record(_ statement: ISO_9075.Rendering) -> [Row] {
        executed.append(statement)
        return results.isEmpty ? [] : results.removeFirst()
    }
}

extension TestDatabase {
    fileprivate struct Connection: ISO_9075.Connection {
        let database: TestDatabase
        var dialect: any ISO_9075.Dialect { Dialect() }

        func execute(_ statement: ISO_9075.Rendering) async throws(ISO_9075.Error) -> Int {
            await database.record(statement).count
        }

        func fetchAll<Value: Sendable>(
            _ statement: ISO_9075.Rendering,
            decode: (any ISO_9075.Row) throws(ISO_9075.Error) -> Value
        ) async throws(ISO_9075.Error) -> [Value] {
            try await database.record(statement).map { row throws(ISO_9075.Error) in try decode(row) }
        }
    }
}
