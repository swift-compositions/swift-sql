public import ISO_9075_Call_Level_Interface

public struct Migrator<Database: ISO_9075.Database>: Sendable {
    public private(set) var migrations: [Migration<Database.Connection>]

    public init(_ migrations: [Migration<Database.Connection>] = []) {
        self.migrations = migrations
    }
}

extension Migrator {
    public enum Error: Swift.Error, Hashable, Sendable {
        case database(ISO_9075.Error)
        case migration(name: String, ISO_9075.Error)
    }
}

extension Migrator {
    public static var appliedTable: ISO_9075.Identifier { ISO_9075.Identifier("_sql_migrations") }

    public var names: [String] { migrations.map(\.name) }

    public mutating func register(
        _ name: String,
        up: @escaping @Sendable (Database.Connection) async throws(ISO_9075.Error) -> Void
    ) {
        migrations.append(Migration(name: name, up: up))
    }

    public mutating func register(_ migration: Migration<Database.Connection>) {
        migrations.append(migration)
    }

    public func pending(applied: Set<String>) -> [Migration<Database.Connection>] {
        migrations.filter { !applied.contains($0.name) }
    }

    public func migrate(_ database: Database) async throws(Error) {
        let applied: Set<String>
        do {
            _ = try await database.execute(
                """
                CREATE TABLE IF NOT EXISTS \(Self.appliedTable) (
                    \(quote: "name") TEXT PRIMARY KEY,
                    \(quote: "appliedAt") TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
                )
                """
            )
            applied = Set(
                try await database.read { (connection: Database.Connection) throws(ISO_9075.Error) -> [String] in
                    try await connection.fetchAll("SELECT \(quote: "name") FROM \(Self.appliedTable)") {
                        row throws(ISO_9075.Error) in
                        switch try row.value(named: "name") {
                        case .text(let name): name
                        case let value: throw .decoding("a migration name, not \(value)")
                        }
                    }
                }
            )
        } catch {
            throw .database(error)
        }
        for migration in pending(applied: applied) {
            try await apply(migration, to: database)
        }
    }

    private func apply(_ migration: Migration<Database.Connection>, to database: Database) async throws(Error) {
        do {
            try await database.write { (connection: Database.Connection) throws(ISO_9075.Error) in
                try await migration.up(connection)
                _ = try await connection.execute(
                    "INSERT INTO \(Self.appliedTable) (\(quote: "name")) VALUES (\(.text(migration.name)))"
                )
            }
        } catch {
            throw .migration(name: migration.name, error)
        }
    }
}
