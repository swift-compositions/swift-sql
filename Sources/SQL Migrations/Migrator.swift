public import ISO_9075_Call_Level_Interface

public struct Migrator<Database: ISO_9075.Database>: Sendable {
    public private(set) var migrations: [Migration<Database.Connection>]

    /// The table that records which migrations ran. Two schemas that share a database each name their own.
    public let table: ISO_9075.Identifier

    public init(_ migrations: [Migration<Database.Connection>] = [], table: ISO_9075.Identifier = Self.defaultTable) {
        self.migrations = migrations
        self.table = table
    }
}

extension Migrator {
    public enum Error: Swift.Error, Hashable, Sendable {
        case database(ISO_9075.Error)
        case migration(name: String, ISO_9075.Error)
        case duplicate(name: String)
    }
}

extension Migrator {
    public static var defaultTable: ISO_9075.Identifier { ISO_9075.Identifier("_sql_migrations") }

    public var names: [String] { migrations.map(\.name) }

    public mutating func register(
        _ name: String,
        up: @escaping @Sendable (Database.Connection) throws(ISO_9075.Error) -> Void
    ) {
        migrations.append(Migration(name: name, up: up))
    }

    public mutating func register(_ migration: Migration<Database.Connection>) {
        migrations.append(migration)
    }

    public func pending(applied: Set<String>) -> [Migration<Database.Connection>] {
        migrations.filter { !applied.contains($0.name) }
    }

    /// The first name registered twice, if any.
    public var duplicate: String? {
        var seen: Set<String> = []
        return names.first { !seen.insert($0).inserted }
    }

    /// Runs every migration not yet recorded, in order. A name registered twice is refused before anything runs.
    public func migrate(_ database: Database) async throws(Error) {
        if let duplicate { throw .duplicate(name: duplicate) }
        let applied: Set<String>
        do {
            _ = try await database.execute(
                """
                CREATE TABLE IF NOT EXISTS \(table) (
                    \(quote: "name") TEXT PRIMARY KEY,
                    \(quote: "appliedAt") TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
            applied = try await database.read { (connection: Database.Connection) throws(ISO_9075.Error) -> Set<String> in
                try self.applied(in: connection)
            }
        } catch {
            throw .database(error)
        }
        for migration in pending(applied: applied) {
            try await apply(migration, to: database)
        }
    }

    /// The names of the migrations recorded as applied on `connection`, which must hold the bookkeeping table.
    public func applied(in connection: Database.Connection) throws(ISO_9075.Error) -> Set<String> {
        Set(
            try connection.fetchAll("SELECT \(quote: "name") FROM \(table)") {
                row throws(ISO_9075.Error) in
                switch try row.value(named: "name") {
                case .text(let name): name
                case let value: throw .decoding("a migration name, not \(value)")
                }
            }
        )
    }

    /// Records `name` as applied on `connection`, inside the caller's transaction.
    public func record(_ name: String, in connection: Database.Connection) throws(ISO_9075.Error) {
        _ = try connection.execute("INSERT INTO \(table) (\(quote: "name")) VALUES (\(.text(name)))")
    }

    private func apply(_ migration: Migration<Database.Connection>, to database: Database) async throws(Error) {
        do {
            try await database.write { (connection: Database.Connection) throws(ISO_9075.Error) in
                try migration.up(connection)
                try record(migration.name, in: connection)
            }
        } catch {
            throw .migration(name: migration.name, error)
        }
    }
}
