# swift-sql

Use this package to build SQL statements from Swift types and to decode result rows back into them, when the database and driver are supplied by another package. Start from `Table`, declared with the `@Table` macro from the SQL Macros product, and from `Migrator` for migrations. If you want a ready SQLite store, use swift-sqlite. If you want PostgreSQL, use swift-postgresql. If you need the dialect and connection types a statement is rendered and run with, use swift-iso-9075.

## Laws

- A statement is a fragment, not a string. A dialect from swift-iso-9075 turns it into SQL with one placeholder per value, in order, and returns the values beside it. The package ships no dialect or driver, except `TestDatabase`, which records what it is given.
- Snapshots from `assertQuery` and the `.sql` snapshotting show values inline. They are not what a dialect sends.
- Comparing with `==` or `!=` on an expression does not compile. `eq` and `neq` compare with `=` and `<>`, so a null on either side never matches. `is` and `isNot` compare null-safely.
- In an update, a plain Swift value assigned to a column does not compile. Wrap it in `#bind`.
- A stored property whose type cannot be a column is a compile error in `@Table`. Give it `@Column(as:)` or `@Ephemeral`. With the CasePaths trait, an enum table's associated value must not be optional.
- Clauses of the same kind combine with AND, each in parentheses. Adding two `Where` values drops duplicate predicates.
- A statement with nothing to do renders as an empty fragment, not as an error: `Table.none`, an insert with no rows, an update with no assignments. Skip it before executing.
- An insert with an update filter but no `DO UPDATE` assignments traps at render time.
- A draft with an absent primary key renders `DEFAULT`, or whatever the dialect spells as its default key. An offset without a limit renders the dialect's unbounded limit, `LIMIT ALL` by default.
- With the CasePaths trait, an enum table binds the active case and NULL for the others. It decodes the case whose column is set.
- A `UInt64` above `Int64.max` binds as an invalid value that carries a failure. It is never truncated.
- `Time.Instant.ISO8601Representation` stores an instant as the text a timestamp binding writes. Text that is not a timestamp throws `QueryDecodingError.dataCorrupted`, and a missing value throws `.missingRequiredColumn`.
- `Migrator` runs pending migrations in registration order and tracks them by name in the `_sql_migrations` table. Each runs in one write together with its record. A failing migration throws `Migrator.Error.migration(name:_:)`, is not recorded, and leaves the earlier ones applied. A migration registered under a new name runs even when later ones have already been applied.
