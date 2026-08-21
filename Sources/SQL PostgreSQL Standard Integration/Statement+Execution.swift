#if PostgreSQLStandardIntegration

    public import PostgreSQL_Standard
    public import SQL

    extension Statement {

        public func execute(_ database: any SQL.Database) async throws(SQL.Error) {
            let query = try SQL.Query(self)
            _ = try await database.execute(query)
        }
    }

#endif
