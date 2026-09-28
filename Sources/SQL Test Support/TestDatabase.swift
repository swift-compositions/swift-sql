public import ISO_9075_Call_Level_Interface
internal import Synchronization

public final class TestDatabase: ISO_9075.Database {
    private let state = Mutex(State())

    public init() {}

    public var executed: [ISO_9075.Rendering] { state.withLock { $0.executed } }

    public var scopes: [Scope] { state.withLock { $0.scopes } }
}

extension TestDatabase {
    public enum Scope: Hashable, Sendable {
        case read
        case write
        case rollback
    }

    struct State {
        var executed: [ISO_9075.Rendering] = []
        var scopes: [Scope] = []
        var results: [[Row]] = []
    }

    public struct Dialect: ISO_9075.Dialect {
        public func placeholder(_ offset: Int) -> String { "$\(offset)" }
    }

    public struct Row: ISO_9075.Row, Sendable {
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
        state.withLock { $0.results.append(rows) }
    }

    public func read<Value: Sendable>(
        _ body: @Sendable (Connection) throws(ISO_9075.Error) -> Value
    ) async throws(ISO_9075.Error) -> Value {
        try scope(.read, body)
    }

    public func write<Value: Sendable>(
        _ body: @Sendable (Connection) throws(ISO_9075.Error) -> Value
    ) async throws(ISO_9075.Error) -> Value {
        try scope(.write, body)
    }

    public func withRollback<Value: Sendable>(
        _ body: @Sendable (Connection) throws(ISO_9075.Error) -> Value
    ) async throws(ISO_9075.Error) -> Value {
        try scope(.rollback, body)
    }

    private func scope<Value>(
        _ scope: Scope,
        _ body: (Connection) throws(ISO_9075.Error) -> Value
    ) throws(ISO_9075.Error) -> Value {
        state.withLock { $0.scopes.append(scope) }
        return try body(Connection(database: self))
    }

    fileprivate func record(_ statement: ISO_9075.Rendering) -> [Row] {
        state.withLock { state in
            state.executed.append(statement)
            return state.results.isEmpty ? [] : state.results.removeFirst()
        }
    }
}

extension TestDatabase {
    public struct Connection: ISO_9075.Connection {
        let database: TestDatabase
        public var dialect: Dialect { Dialect() }

        public func execute(_ statement: ISO_9075.Rendering) throws(ISO_9075.Error) -> Int {
            database.record(statement).count
        }

        public func fetchAll<Value>(
            _ statement: ISO_9075.Rendering,
            decode: (Row) throws(ISO_9075.Error) -> Value
        ) throws(ISO_9075.Error) -> [Value] {
            try database.record(statement).map { row throws(ISO_9075.Error) in try decode(row) }
        }
    }
}
