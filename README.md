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

`SQL.Reader.cursor(_:decode:)` asks the database owner to transfer a checked-out
lease into a pull-driven `SQL.Cursor`. It does not collect rows: each cursor
advance asks the provider for one more decoded value. The cursor is noncopyable
and non-Sendable; each advance consumes it and returns the only continuation
with the decoded element.

```swift
func printRows(_ cursor: consuming SQL.Cursor<Int64>) async throws(SQL.Error) {
    let next = await cursor.next()
    switch consume next {
    case .element(let id, let cursor):
        print(id)
        try await printRows(cursor)
    case .exhausted:
        return
    case .failure(let error):
        throw error
    }
}

let cursor = try await database.cursor(
    SQL.Query(sql: "SELECT id FROM users")
) { row in
    try row.int64("id")
}
try await printRows(cursor)
```

The cursor uniquely retains the provider context across every continuation.
Exhaustion and successful close resolve it reusable; iteration failure, close
failure, and cancellation resolve it invalid. Dropping a live cursor invokes the
provider's synchronous invalid fallback. Providers map all driver errors to
`SQL.Error`; cancellation is reported as `SQL.Error.cancelled`.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
