extension Schema {
    /// Access to statements that drop schema objects associated with a table declaration.
    public struct Drop<Root: Table>: Sendable {
        package init() {}
    }
}

extension Table {
    /// Statements that drop schema objects associated with this table.
    public static var drop: Schema.Drop<Self> { Schema.Drop() }
}
