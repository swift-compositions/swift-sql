public import ISO_9075_Call_Level_Interface

public struct Migration<Connection: ISO_9075.Connection>: Sendable {
    public let name: String
    public let up: @Sendable (Connection) throws(ISO_9075.Error) -> Void

    public init(
        name: String,
        up: @escaping @Sendable (Connection) throws(ISO_9075.Error) -> Void
    ) {
        self.name = name
        self.up = up
    }
}
