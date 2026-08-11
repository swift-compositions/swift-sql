# swift-sql

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Database-agnostic SQL query and statement types for Swift, with connection, row,
and value protocols that a driver conforms to.

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-sql.git", branch: "main")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "SQL", package: "swift-sql")
    ]
)
```

The driver integration and the test doubles are separate products, so neither is
linked into a target that does not ask for it:

| Product | Adds |
|---|---|
| `SQL PostgreSQL Standard Integration` | PostgreSQL statement execution and row decoding |
| `SQL Test Support` | in-memory `TestDatabase`, `TestConnection`, and `TestRow` |

## Error Handling

Query and statement operations throw `SQL.Error`, declared by this package.
Driver-specific failures are mapped into it at the integration boundary, so a
caller written against the protocols handles one error type regardless of which
database backs it.

## Streaming rows

`SQL.Connection.fetchCursor(_:decode:)` opens a connection-scoped,
pull-driven `SQL.Cursor`. It does not collect rows: each iterator advance asks
the provider for one more decoded value. Consume it inside the `read` or
transaction scope that supplied the connection.

```swift
try await database.read { connection in
    let cursor = try await connection.fetchCursor(SQL.Query(sql: "SELECT id FROM users")) { row in
        try row.int64("id")
    }
    for try await id in cursor {
        print(id)
    }
}
```

The cursor releases provider resources exactly once when it is exhausted,
closed, cancelled, or fails. A cursor is a single shared stream: do not create
concurrent consumers from copied cursors or iterators. Providers map all driver
errors to `SQL.Error`; cancellation is reported as `SQL.Error.cancelled`.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
