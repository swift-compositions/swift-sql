extension FTS5 {
    /// A tokenizer accepted by an FTS5 virtual table.
    public struct Tokenizer: Sendable {
        package let specification: String

        package init(specification: String) {
            self.specification = specification
        }
    }
}

extension FTS5.Tokenizer {
    /// SQLite's ASCII tokenizer.
    ///
    /// - Parameters:
    ///   - tokenCharacters: Additional characters to treat as part of a token.
    ///   - separators: Additional characters to treat as token separators.
    public static func ascii(
        tokenCharacters: String? = nil,
        separators: String? = nil
    ) -> Self {
        Self(
            specification: tokenizer(
                "ascii",
                options: [
                    ("tokenchars", tokenCharacters),
                    ("separators", separators),
                ]
            )
        )
    }

    /// SQLite's Unicode 6.1 tokenizer.
    ///
    /// - Parameters:
    ///   - diacritics: How the tokenizer handles diacritics.
    ///   - categories: Unicode general categories to include as token characters.
    ///   - tokenCharacters: Additional characters to treat as part of a token.
    ///   - separators: Additional characters to treat as token separators.
    public static func unicode61(
        diacritics: FTS5.Diacritics = .legacy,
        categories: String? = nil,
        tokenCharacters: String? = nil,
        separators: String? = nil
    ) -> Self {
        Self(
            specification: tokenizer(
                "unicode61 remove_diacritics \(diacritics.value)",
                options: [
                    ("categories", categories),
                    ("tokenchars", tokenCharacters),
                    ("separators", separators),
                ]
            )
        )
    }

    /// SQLite's Porter stemming tokenizer using the Unicode 6.1 tokenizer beneath it.
    public static func porter(
        diacritics: FTS5.Diacritics = .legacy,
        categories: String? = nil,
        tokenCharacters: String? = nil,
        separators: String? = nil
    ) -> Self {
        let base = unicode61(
            diacritics: diacritics,
            categories: categories,
            tokenCharacters: tokenCharacters,
            separators: separators
        )
        return Self(specification: "porter \(base.specification)")
    }

    /// SQLite's trigram tokenizer.
    ///
    /// The typed mode excludes SQLite's invalid combination of case-sensitive matching and
    /// diacritic removal.
    public static func trigram(_ mode: FTS5.Trigram = .standard) -> Self {
        switch mode {
        case .standard:
            Self(specification: "trigram")
        case .sensitive:
            Self(specification: "trigram case_sensitive 1")
        case .folding:
            Self(specification: "trigram remove_diacritics 1")
        }
    }
}

private func tokenizer(
    _ name: String,
    options: [(String, String?)]
) -> String {
    options.reduce(into: name) { specification, option in
        guard let value = option.1 else { return }
        let escaped = value
            .split(separator: "'", omittingEmptySubsequences: false)
            .joined(separator: "''")
        specification.append(" \(option.0) '\(escaped)'")
    }
}
