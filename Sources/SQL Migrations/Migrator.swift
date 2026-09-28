public import ISO_9075_Call_Level_Interface

public struct Migrator: Sendable {
    public private(set) var migrations: [Migration]

    public init(_ migrations: [Migration] = []) {
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
    public static let appliedTable = ISO_9075.Identifier("_sql_migrations")

    public var names: [String] { migrations.map(\.name) }

    public mutating func register(
        _ name: String,
        up: @escaping @Sendable (any ISO_9075.Connection) async throws(ISO_9075.Error) -> Void
    ) {
        migrations.append(Migration(name: name, up: up))
    }

    public mutating func register(_ migration: Migration) {
        migrations.append(migration)
    }

    public func pending(applied: Set<String>) -> [Migration] {
        migrations.filter { !applied.contains($0.name) }
    }

    public func migrate(_ database: any ISO_9075.Database) async throws(Error) {
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
                try await database.read { (connection: any ISO_9075.Connection) throws(ISO_9075.Error) -> [String] in
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

    private func apply(_ migration: Migration, to database: any ISO_9075.Database) async throws(Error) {
        do {
            try await database.write { (connection: any ISO_9075.Connection) throws(ISO_9075.Error) in
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
