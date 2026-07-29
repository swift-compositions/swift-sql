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
    ],
    dependencies: [
        // Institute L1/L2 vocabulary the value/row surface is expressed in. These are the only
        // dependencies the engine-free core has: the DSL bridge that used to live here — and
        // brought `swift-postgresql-standard` and `swift-byte-primitives` with it — now lives in
        // swift-postgresql-standard as `PostgreSQL Standard SQL Integration`.
        .package(url: "https://github.com/swift-ietf/swift-rfc-4122.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
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

        // MARK: - Tests

        .testTarget(
            name: "SQL Tests",
            dependencies: [
                "SQL",
                "SQL Test Support",
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
