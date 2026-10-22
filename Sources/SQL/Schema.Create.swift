extension Schema {
    /// Access to statements that create schema objects for a table declaration.
    public struct Create<Root: Table>: Sendable {
        package init() {}
    }
}

extension Table {
    /// Statements that create schema objects associated with this table.
    public static var create: Schema.Create<Self> { Schema.Create() }
}
