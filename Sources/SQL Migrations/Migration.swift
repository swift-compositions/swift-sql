public import ISO_9075_Call_Level_Interface

public struct Migration: Sendable {
    public let name: String
    public let up: @Sendable (any ISO_9075.Connection) async throws(ISO_9075.Error) -> Void

    public init(
        name: String,
        up: @escaping @Sendable (any ISO_9075.Connection) async throws(ISO_9075.Error) -> Void
    ) {
        self.name = name
        self.up = up
    }
}
