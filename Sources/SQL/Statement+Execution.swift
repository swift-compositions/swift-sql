public import ISO_9075_Call_Level_Interface

extension Statement {
    @inlinable
    public func execute(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) where QueryValue == () {
        _ = try connection.execute(query)
    }

    @inlinable
    public func fetchAll(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> [QueryValue.QueryOutput] where QueryValue: QueryRepresentable {
        try connection.fetchAll(query) { decoder throws(QueryDecodingError) in try QueryValue(decoder: &decoder).queryOutput }
    }

    @inlinable
    public func fetchOne(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> QueryValue.QueryOutput? where QueryValue: QueryRepresentable {
        try fetchAll(connection).first
    }

    @inlinable
    public func fetchAll<each Value: QueryRepresentable>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> [(repeat (each Value).QueryOutput)] where QueryValue == (repeat each Value) {
        try connection.fetchAll(query) { decoder throws(QueryDecodingError) in
            try decoder.decodeColumns((repeat each Value).self)
        }
    }

    @inlinable
    public func fetchOne<each Value: QueryRepresentable>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> (repeat (each Value).QueryOutput)? where QueryValue == (repeat each Value) {
        try fetchAll(connection).first
    }
}

extension SelectStatement where QueryValue == (), Joins == () {
    @inlinable
    public func fetchCount(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> Int {
        try asSelect().count().fetchOne(connection) ?? 0
    }

    @inlinable
    public func fetchAll(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> [From.QueryOutput] {
        try connection.fetchAll(query) { decoder throws(QueryDecodingError) in try From(decoder: &decoder).queryOutput }
    }

    @inlinable
    public func fetchOne(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> From.QueryOutput? {
        try connection.fetchAll(asSelect().limit(1).query) { decoder throws(QueryDecodingError) in
            try From(decoder: &decoder).queryOutput
        }
        .first
    }
}

extension SelectStatement where QueryValue == () {
    @inlinable
    public func fetchAll<each Join: Table>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> [(From.QueryOutput, repeat (each Join).QueryOutput)] where Joins == (repeat each Join) {
        try connection.fetchAll(query) { decoder throws(QueryDecodingError) in
            try decoder.decodeColumns((From, repeat each Join).self)
        }
    }

    @inlinable
    public func fetchOne<each Join: Table>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> (From.QueryOutput, repeat (each Join).QueryOutput)? where Joins == (repeat each Join) {
        try connection.fetchAll(asSelect().limit(1).query) { decoder throws(QueryDecodingError) in
            try decoder.decodeColumns((From, repeat each Join).self)
        }
        .first
    }
}

extension Table {
    @inlinable
    public static func fetchAll(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> [QueryOutput] {
        try all.fetchAll(connection)
    }

    @inlinable
    public static func fetchOne(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> QueryOutput? {
        try all.fetchOne(connection)
    }

    @inlinable
    public static func fetchCount(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> Int {
        try all.fetchCount(connection)
    }
}
