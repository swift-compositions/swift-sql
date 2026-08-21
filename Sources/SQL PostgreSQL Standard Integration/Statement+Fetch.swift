#if PostgreSQLStandardIntegration

    public import PostgreSQL_Standard
    public import SQL

    extension Statement where QueryValue: QueryRepresentable, QueryValue.QueryOutput: Sendable {

        public func fetchAll(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> [QueryValue.QueryOutput] {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchAll(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> QueryValue.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try QueryValue(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }

        public func fetchOne(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> QueryValue.QueryOutput? {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchOne(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> QueryValue.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try QueryValue(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }
    }

    extension Statement
    where QueryValue == (), Joins == (), From: Sendable, From.QueryOutput: Sendable {

        public func fetchAll(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> [From.QueryOutput] {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchAll(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> From.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try From(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }

        public func fetchOne(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> From.QueryOutput? {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchOne(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> From.QueryOutput in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try From(decoder: &decoder).queryOutput
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }
    }

    extension Statement {

        @_disfavoredOverload
        public func fetchAll<each C: QueryRepresentable>(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> [(repeat (each C).QueryOutput)]
        where
            QueryValue == (repeat each C), repeat each C: Sendable,
            repeat (each C).QueryOutput: Sendable
        {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchAll(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> (repeat (each C).QueryOutput) in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try decoder.decodeColumns((repeat each C).self)
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }

        @_disfavoredOverload
        public func fetchOne<each C: QueryRepresentable>(
            _ database: any SQL.Database
        ) async throws(SQL.Error) -> (repeat (each C).QueryOutput)?
        where
            QueryValue == (repeat each C), repeat each C: Sendable,
            repeat (each C).QueryOutput: Sendable
        {
            let query = try SQL.Query(self)
            return try await database.write { connection throws(SQL.Error) in
                try await connection.fetchOne(query) {
                    (row: any SQL.Row) throws(SQL.Error) -> (repeat (each C).QueryOutput) in
                    var decoder = SQL.RowDecoder(row: row)
                    do {
                        return try decoder.decodeColumns((repeat each C).self)
                    } catch let error as SQL.Error {
                        throw error
                    } catch {
                        throw SQL.Error.decoding("\(error)")
                    }
                }
            }
        }
    }

#endif
