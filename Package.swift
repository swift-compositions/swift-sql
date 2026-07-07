// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-sql",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "SQL", targets: ["SQL"]),
        .library(name: "SQL Test Support", targets: ["SQL Test Support"]),
        .library(name: "SQL Dependencies Integration", targets: ["SQL Dependencies Integration"]),
        .library(
            name: "SQL PostgreSQL Standard Integration",
            targets: ["SQL PostgreSQL Standard Integration"]
        ),
    ],
    dependencies: [
        // Institute L1/L2 vocabulary the value/row surface is expressed in.
        .package(url: "https://github.com/swift-ietf/swift-rfc-4122.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
        // Integration-only deps — each is imported by a single opt-in integration target.
        // `traits: []` opts out of swift-dependencies' `Clocks` trait: the integration needs only
        // the `Dependencies` product, and leaving `Clocks` active pulls in the trait-gated
        // `Clocks Dependency` → `swift-clock-primitives` product edge (validated graph-wide).
        .package(
            url: "https://github.com/swift-foundations/swift-dependencies.git",
            branch: "main",
            traits: ["Clocks"]
        ),
        // Path-form (not URL-form) is required: swift-postgresql-standard's macro target includes
        // `Structured Queries Primitives Support` sources via a RELATIVE symlink that only resolves
        // in the canonical sibling workspace layout. A URL/mirror dependency clones the package into
        // `.build/checkouts`, which breaks the symlink (the macro then can't see `Inflection.swift`
        // → `'String' has no member 'lowerCamelCased'`). A path dependency is used in place, so the
        // symlink resolves. See the target-level report on this upstream packaging constraint.
        .package(path: "/Users/coen/Developer/swift-standards/swift-postgresql-standard"),
    ],
    targets: [
        // MARK: - SQL (engine-free execution interface)

        .target(
            name: "SQL",
            dependencies: [
                .product(name: "RFC 4122", package: "swift-rfc-4122"),
                .product(name: "Time Primitive", package: "swift-time-primitives"),
            ],
            path: "Sources/SQL"
        ),

        // MARK: - SQL Test Support (engine-free scripted test double)

        .target(
            name: "SQL Test Support",
            dependencies: [
                "SQL"
            ],
            path: "Sources/SQL Test Support"
        ),

        // MARK: - SQL Dependencies Integration (defaultDatabase key)

        .target(
            name: "SQL Dependencies Integration",
            dependencies: [
                "SQL",
                .product(name: "Dependencies", package: "swift-dependencies"),
            ],
            path: "Sources/SQL Dependencies Integration"
        ),

        // MARK: - SQL PostgreSQL Standard Integration (the DSL bridge)

        .target(
            name: "SQL PostgreSQL Standard Integration",
            dependencies: [
                "SQL",
                .product(name: "PostgreSQL Standard", package: "swift-postgresql-standard"),
            ],
            path: "Sources/SQL PostgreSQL Standard Integration"
        ),

        // MARK: - Tests

        .testTarget(
            name: "SQL Tests",
            dependencies: [
                "SQL",
                "SQL Test Support",
                "SQL Dependencies Integration",
                "SQL PostgreSQL Standard Integration",
                // The bridge tests construct DSL statements directly, so the test target imports
                // the DSL module (QueryFragment / QueryBinding / SQLQueryExpression).
                .product(name: "PostgreSQL Standard", package: "swift-postgresql-standard"),
            ],
            path: "Tests/SQL Tests"
        ),
    ],
    swiftLanguageModes: [.v6]
)

// Membrane build settings, mirroring the swift-server trio. InternalImportsByDefault is the
// load-bearing setting: it keeps integration-only imports (Dependencies, PostgreSQL Standard,
// and the Foundation types the DSL bridge touches transitively) from leaking through the public
// surface of the engine-free core. The stricter swift-json ecosystem bundle
// (strictMemorySafety + NonisolatedNonsendingByDefault + the Lifetime experimental features) is
// deliberately NOT applied here: this package's surface is async-protocol- and actor-heavy, and
// the trio is the settings baseline ratified for the swift-server membrane it descends from.
for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let membrane: [SwiftSetting] = [
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("ExistentialAny"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + membrane
}
