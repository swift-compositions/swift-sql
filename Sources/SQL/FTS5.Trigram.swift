extension FTS5 {
    /// A valid set of options for the trigram tokenizer.
    public enum Trigram: Sendable {
        /// Matches case-insensitively while preserving diacritics.
        case standard

        /// Matches case-sensitively while preserving diacritics.
        case sensitive

        /// Matches case-insensitively after removing diacritics.
        case folding
    }
}
