// swift-linter-tools-version: 0.1
// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-sql open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-sql project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

import Linter
import Linter_Institute_Rules

// URL-form dependency — matches the live convention used by 390/396 of the
// existing fleet's Lint.swift files (see parent-adoption-sample.txt). Path
// form is the pre-publish/local-dev alternative (commented below); rotate to
// it only while swift-sql and swift-institute-linter-rules are both
// being developed against un-pushed local changes, per [LINT-SETUP-004]/[PKG-DEP-*].
Lint.run(dependencies: [
    .package(
        url: "https://github.com/swift-foundations/swift-institute-linter-rules.git",
        branch: "main",
        products: ["Linter Institute Rules"]
    ),
    // Path-form alternative (local dev only) — see relpath-table.txt for the
    // per-org relative path. Uncomment and delete the url-form entry above
    // to switch:
    // .package(
    //     path: "../swift-institute-linter-rules",
    //     products: ["Linter Institute Rules"]
    // ),
]) {
    Lint.Rule.Bundle.institute
    // If swift-sql owns a brand vocabulary, narrow with
    // `.excluding(rules: [...])` per [LINT-EXCLUDE-001]/[LINT-EXCLUDE-004] —
    // each excluded rule needs an in-file justification comment AND a direct
    // leaf-module import (e.g. `import Institute_Linter_Rule_Naming`) per
    // [LINT-BUNDLE-003] (SE-0444 MemberImportVisibility). Do not add
    // `.excluding(rules:)` speculatively — only after running the linter and
    // observing which rules fire on this package's own legitimate surface.
}
