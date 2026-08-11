// swift-tools-version: 6.3.3

import PackageDescription

let package = Package(
    name: "swift-sql",
    platforms: [
        .macOS(.v26)
    ],
    products: [
        .library(name: "SQL", targets: ["SQL"]),
        .library(name: "SQL Test Support", targets: ["SQL Test Support"]),
        .library(
            name: "SQL PostgreSQL Standard Integration",
            targets: ["SQL PostgreSQL Standard Integration"]
        ),
    ],
    traits: [
        .trait(
            name: "PostgreSQLStandardIntegration",
            description: """
                Build the PostgreSQL Standard DSL bridge.

                OFF by default, and the default is the point: the dialect dependency is what                 takes this package's resolved closure from 29 packages to 154.

                An opt-in *product* does not avoid that. SwiftPM resolves a package's                 `dependencies:` for the whole package regardless of which product a consumer                 imports — products gate linking, only a trait gates resolution.
                """
        )
    ],
    dependencies: [
        // Institute L1/L2 vocabulary the value/row surface is expressed in. These are the only
        // dependencies the engine-free core has: the DSL bridge that used to live here — and
        // brought `swift-postgresql-standard` and `swift-byte-primitives` with it — now lives in
        // swift-postgresql-standard as `PostgreSQL Standard SQL Integration`.
        .package(url: "https://github.com/swift-ietf/swift-rfc-4122.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
        // Source-law fixture for the public move-only checked-out handle that `SQL.Cursor` must
        // retain through iteration. The SQL product remains pool-independent.
        .package(
            url: "https://github.com/swift-primitives/swift-pool-primitives.git",
            revision: "b7c710c945b7c8467b4521c3a2d5b00539275593"
        ),
        // Bridge-only, referenced solely under the `PostgreSQLStandardIntegration` trait so they
        // are pruned from resolution when it is off.
        .package(url: "https://github.com/swift-primitives/swift-byte-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-standards/swift-postgresql-standard.git", branch: "main"),
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

        // MARK: - SQL PostgreSQL Standard Integration (the DSL bridge)
        //
        // Placement is the ratified 2026-07-06 architecture decision: the bridge lives here, and
        // swift-sql (L3 foundations) -> swift-postgresql-standard (L2 standards) is downward and
        // legal. The trait gates the resolve cost; it does not change the direction.

        .target(
            name: "SQL PostgreSQL Standard Integration",
            dependencies: [
                "SQL",
                .product(
                    name: "Byte Primitives",
                    package: "swift-byte-primitives",
                    condition: .when(traits: ["PostgreSQLStandardIntegration"])
                ),
                .product(
                    name: "PostgreSQL Standard",
                    package: "swift-postgresql-standard",
                    condition: .when(traits: ["PostgreSQLStandardIntegration"])
                ),
            ],
            path: "Sources/SQL PostgreSQL Standard Integration"
        ),

        // MARK: - Tests

        .testTarget(
            name: "SQL Tests",
            dependencies: [
                "SQL",
                "SQL Test Support",
                "SQL PostgreSQL Standard Integration",
                .product(name: "Pool Primitives", package: "swift-pool-primitives"),
                .product(
                    name: "Byte Primitives",
                    package: "swift-byte-primitives",
                    condition: .when(traits: ["PostgreSQLStandardIntegration"])
                ),
                .product(
                    name: "PostgreSQL Standard",
                    package: "swift-postgresql-standard",
                    condition: .when(traits: ["PostgreSQLStandardIntegration"])
                ),
                // `@Table` is a macro attribute, unreachable through the runtime library's
                // `@_exported import`, so the fixtures need the macro product directly.
                .product(
                    name: "PostgreSQL Standard Macros",
                    package: "swift-postgresql-standard",
                    condition: .when(traits: ["PostgreSQLStandardIntegration"])
                ),
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
