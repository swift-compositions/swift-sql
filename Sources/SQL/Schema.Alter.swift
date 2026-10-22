extension Schema {
    /// Access to typed alterations for a table declaration.
    public struct Alter<Root: Table>: Sendable {
        package init() {}
    }
}

extension Table {
    /// Typed alterations for this table.
    public static var alter: Schema.Alter<Self> { Schema.Alter() }
}
