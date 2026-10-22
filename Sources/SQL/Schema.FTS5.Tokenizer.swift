extension Schema.FTS5 {
    /// A typed FTS5 tokenizer configuration.
    public struct Tokenizer: Hashable, Sendable {
        package let text: String

        package init(_ text: String) {
            self.text = text
        }

        /// The FTS5 ASCII tokenizer.
        public static var ascii: Self { Self("ascii") }

        /// The FTS5 Unicode 6.1 tokenizer and its supported options.
        public static func unicode61(
            diacritics: Diacritics = .legacy,
            categories: String? = nil,
            separators: String? = nil,
            tokens: String? = nil
        ) -> Self {
            var components = ["unicode61", "remove_diacritics", "\(diacritics.rawValue)"]
            if let categories {
                components.append(contentsOf: ["categories", "'\(categories)'"])
            }
            if let separators {
                components.append(contentsOf: ["separators", "'\(separators)'"])
            }
            if let tokens {
                components.append(contentsOf: ["tokenchars", "'\(tokens)'"])
            }
            return Self(components.joined(separator: " "))
        }

        /// The FTS5 Porter stemmer wrapping another tokenizer.
        public static func porter(_ base: Self = .unicode61()) -> Self {
            Self("porter \(base.text)")
        }

        /// The FTS5 trigram tokenizer and its supported options.
        public static func trigram(
            caseSensitive: Bool = false,
            diacritics: Bool = false
        ) -> Self {
            Self(
                "trigram case_sensitive \(caseSensitive ? 1 : 0) remove_diacritics \(diacritics ? 1 : 0)"
            )
        }
    }
}
