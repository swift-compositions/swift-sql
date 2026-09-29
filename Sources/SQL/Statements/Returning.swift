public import ISO_9075_Foundation

extension Delete {
    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
    ) -> Delete<From, (repeat each QueryValue)> {
        let columns = selection(From.columns)
        var fragments: [ISO_9075.Fragment] = []
        for column in repeat each columns {
            fragments.append(column.returningFragment)
        }
        return returning(fragments: fragments)
    }

    public func returning(_ selection: (From.TableColumns) -> From.TableColumns) -> Delete<From, From> {
        returning(fragments: From.TableColumns.allColumns.map(\.returningFragment))
    }
}

extension Insert {
    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (Into.TableColumns) -> (repeat TableColumn<Into, each QueryValue>)
    ) -> Insert<Into, (repeat each QueryValue)> {
        let columns = selection(Into.columns)
        var fragments: [ISO_9075.Fragment] = []
        for column in repeat each columns {
            fragments.append(column.returningFragment)
        }
        return returning(fragments: fragments)
    }

    public func returning(_ selection: (Into.TableColumns) -> Into.TableColumns) -> Insert<Into, Into> {
        returning(fragments: Into.TableColumns.allColumns.map(\.returningFragment))
    }
}

extension Update {
    public func returning<each QueryValue: QueryRepresentable>(
        _ selection: (From.TableColumns) -> (repeat TableColumn<From, each QueryValue>)
    ) -> Update<From, (repeat each QueryValue)> {
        let columns = selection(From.columns)
        var fragments: [ISO_9075.Fragment] = []
        for column in repeat each columns {
            fragments.append(column.returningFragment)
        }
        return returning(fragments: fragments)
    }

    public func returning(_ selection: (From.TableColumns) -> From.TableColumns) -> Update<From, From> {
        returning(fragments: From.TableColumns.allColumns.map(\.returningFragment))
    }
}
