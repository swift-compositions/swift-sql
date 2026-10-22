extension FTS5 {
    /// The Unicode tokenizer's diacritic handling.
    public enum Diacritics: Sendable {
        /// Keeps diacritics when tokenizing text.
        case keep

        /// Removes diacritics, retaining SQLite's legacy exception for uncommon single-codepoint
        /// characters containing more than one diacritic.
        case legacy

        /// Removes diacritics, including uncommon single-codepoint characters containing more than
        /// one diacritic.
        case complete
    }
}

extension FTS5.Diacritics {
    package var value: Int {
        switch self {
        case .keep: 0
        case .legacy: 1
        case .complete: 2
        }
    }
}
