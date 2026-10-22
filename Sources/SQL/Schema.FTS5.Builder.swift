public import ISO_9075_Foundation

extension Schema.FTS5 {
    /// Builds a typed list of FTS5 fields.
    @resultBuilder
    public enum Builder {
        public static func buildExpression<Definition: _TableColumnExpression>(
            _ column: Definition
        ) -> [ISO_9075.Fragment] {
            column._names.map { "\(quote: $0)" }
        }

        public static func buildExpression<Root: Table>(
            _ field: Field<Root>
        ) -> [ISO_9075.Fragment] {
            field.fragments
        }

        public static func buildBlock(
            _ components: [ISO_9075.Fragment]...
        ) -> [ISO_9075.Fragment] {
            components.flatMap(\.self)
        }

        public static func buildEither(
            first component: [ISO_9075.Fragment]
        ) -> [ISO_9075.Fragment] {
            component
        }

        public static func buildEither(
            second component: [ISO_9075.Fragment]
        ) -> [ISO_9075.Fragment] {
            component
        }

        public static func buildOptional(
            _ component: [ISO_9075.Fragment]?
        ) -> [ISO_9075.Fragment] {
            component ?? []
        }
    }
}
