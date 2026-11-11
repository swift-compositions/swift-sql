public import Cardinal
public import ISO_9075_Call_Level_Interface

extension Statement {
    @inlinable
    public func execute(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) where QueryValue == () {
        _ = try connection.execute(query)
    }

    @inlinable
    public var fetch: Fetching<Self> { Fetching(self) }
}

extension Table {
    @inlinable
    public static var fetch: Fetching<DefaultScope> { all.fetch }
}
