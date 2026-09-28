// swift-tools-version: 6.4

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "swift-sql",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "SQL", targets: ["SQL"]),
        .library(name: "SQL Macros", targets: ["SQL Macros"]),
        .library(name: "SQL Foundation Integration", targets: ["SQL Foundation Integration"]),
        .library(name: "SQL Migrations", targets: ["SQL Migrations"]),
        .library(name: "SQL Test Support", targets: ["SQL Test Support"]),
    ],
    traits: [
        .trait(name: "Tagged", description: "SQL conformances for swift-atoms Tagged"),
        .trait(name: "CasePaths", description: "Enum tables through CasePaths"),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-order.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-case-paths.git", from: "1.7.2"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump.git", from: "1.3.3"),
        .package(url: "https://github.com/swift-iso/swift-iso-9075.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-macro-testing.git", from: "0.6.3"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-4122.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.4"),
        .package(url: "https://github.com/swift-atoms/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "603.0.0"),
        .package(url: "https://github.com/swift-atoms/swift-tagged.git", branch: "main"),
        .package(url: "https://github.com/swift-atoms/swift-time.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "SQL",
            dependencies: [
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "ISO 9075 Foundation", package: "swift-iso-9075"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Order", package: "swift-order"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "RFC 4122", package: "swift-rfc-4122"),
                .product(name: "Tagged", package: "swift-tagged", condition: .when(traits: ["Tagged"])),
                .product(name: "CasePaths", package: "swift-case-paths", condition: .when(traits: ["CasePaths"])),
            ]
        ),
        .macro(
            name: "SQL Macros Implementation",
            dependencies: [
                .product(name: "Standard Library Extensions", package: "swift-standard-library-extensions"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SQL Macros",
            dependencies: [
                "SQL",
                .product(name: "ISO 9075 Foundation", package: "swift-iso-9075"),
                "SQL Macros Implementation",
                .product(name: "CasePaths", package: "swift-case-paths", condition: .when(traits: ["CasePaths"])),
            ]
        ),
        .target(
            name: "SQL Foundation Integration",
            dependencies: [
                "SQL",
                .product(name: "ISO 9075 Foundation", package: "swift-iso-9075"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "RFC 4122", package: "swift-rfc-4122"),
            ]
        ),
        .target(
            name: "SQL Migrations",
            dependencies: [
                .product(name: "ISO 9075 Call-Level Interface", package: "swift-iso-9075"),
            ]
        ),
        .target(
            name: "SQL Test Support",
            dependencies: [
                "SQL",
                .product(name: "ISO 9075 Foundation", package: "swift-iso-9075"),
                .product(name: "ISO 9075 Call-Level Interface", package: "swift-iso-9075"),
                .product(name: "CustomDump", package: "swift-custom-dump"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .testTarget(
            name: "SQL Tests",
            dependencies: [
                "SQL",
                "SQL Macros",
                "SQL Test Support",
                .product(name: "Order", package: "swift-order"),
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
        .testTarget(
            name: "SQL Migrations Tests",
            dependencies: [
                "SQL Migrations",
                "SQL Test Support",
                .product(name: "ISO 9075 Call-Level Interface", package: "swift-iso-9075"),
            ]
        ),
        .testTarget(
            name: "SQL Macros Tests",
            dependencies: [
                "SQL Macros",
                "SQL Macros Implementation",
                .product(name: "MacroTesting", package: "swift-macro-testing"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}
