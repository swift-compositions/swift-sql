extension Schema.FTS5 {
    /// The `unicode61` tokenizer's diacritic-removal behavior.
    public enum Diacritics: Int, Hashable, Sendable {
        /// Preserves diacritics.
        case preserve = 0

        /// Uses FTS5's original diacritic-removal behavior.
        case legacy = 1

        /// Removes diacritics, including the legacy exceptions.
        case thorough = 2
    }
}
