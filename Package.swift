// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-sql",
    platforms: [
        .macOS(.v27)
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

        .package(url: "https://github.com/swift-ietf/swift-rfc-4122.git", branch: "main"),
        .package(
            url: "https://github.com/swift-primitives/swift-time-primitives.git",
            branch: "main"
        ),

        .package(
            url: "https://github.com/swift-primitives/swift-byte-primitives.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-standards/swift-postgresql-standard.git",
            branch: "main"
        ),
    ],
    targets: [

        .target(
            name: "SQL",
            dependencies: [
                .product(name: "RFC 4122", package: "swift-rfc-4122"),
                .product(name: "Time Primitive", package: "swift-time-primitives"),
            ],
            path: "Sources/SQL"
        ),

        .target(
            name: "SQL Test Support",
            dependencies: [
                "SQL"
            ],
            path: "Sources/SQL Test Support"
        ),

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

        .testTarget(
            name: "SQL Tests",
            dependencies: [
                "SQL",
                "SQL Test Support",
                "SQL PostgreSQL Standard Integration",
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

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let membrane: [SwiftSetting] = [
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("ExistentialAny"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + membrane
}
