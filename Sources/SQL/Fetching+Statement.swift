public import Cardinal
public import ISO_9075_Call_Level_Interface

extension Fetching where Base: Statement, Base.QueryValue: QueryRepresentable {
    @inlinable
    public func all(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> [Base.QueryValue.QueryOutput] {
        try connection.fetchAll(base.query) { decoder throws(QueryDecodingError) in
            try Base.QueryValue(decoder: &decoder).queryOutput
        }
    }

    @inlinable
    public func one(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> Base.QueryValue.QueryOutput? {
        try all(connection).first
    }
}

extension Fetching where Base: Statement {
    @inlinable
    public func all<each Value: QueryRepresentable>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> [(repeat (each Value).QueryOutput)] where Base.QueryValue == (repeat each Value) {
        try connection.fetchAll(base.query) { decoder throws(QueryDecodingError) in
            try decoder.decodeColumns((repeat each Value).self)
        }
    }

    @inlinable
    public func one<each Value: QueryRepresentable>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> (repeat (each Value).QueryOutput)? where Base.QueryValue == (repeat each Value) {
        try all(connection).first
    }
}

extension Fetching where Base: SelectStatement, Base.QueryValue == (), Base.Joins == () {
    @inlinable
    public func count(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> Cardinal {
        let rows = try base.asSelect().count().fetch.one(connection) ?? 0
        do throws(Cardinal.Error) {
            return try Cardinal(rows)
        } catch {
            throw .decoding("a row count of \(rows) is no cardinal: \(error)")
        }
    }

    @inlinable
    public func all(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> [Base.From.QueryOutput] {
        try connection.fetchAll(base.query) { decoder throws(QueryDecodingError) in
            try Base.From(decoder: &decoder).queryOutput
        }
    }

    @inlinable
    public func one(_ connection: some ISO_9075.Connection) throws(ISO_9075.Error) -> Base.From.QueryOutput? {
        try connection.fetchAll(base.asSelect().limit(1).query) { decoder throws(QueryDecodingError) in
            try Base.From(decoder: &decoder).queryOutput
        }
        .first
    }
}

extension Fetching where Base: SelectStatement, Base.QueryValue == () {
    @inlinable
    public func all<each Join: Table>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> [(Base.From.QueryOutput, repeat (each Join).QueryOutput)]
    where Base.Joins == (repeat each Join) {
        try connection.fetchAll(base.query) { decoder throws(QueryDecodingError) in
            try decoder.decodeColumns((Base.From, repeat each Join).self)
        }
    }

    @inlinable
    public func one<each Join: Table>(
        _ connection: some ISO_9075.Connection
    ) throws(ISO_9075.Error) -> (Base.From.QueryOutput, repeat (each Join).QueryOutput)?
    where Base.Joins == (repeat each Join) {
        try connection.fetchAll(base.asSelect().limit(1).query) { decoder throws(QueryDecodingError) in
            try decoder.decodeColumns((Base.From, repeat each Join).self)
        }
        .first
    }
}
