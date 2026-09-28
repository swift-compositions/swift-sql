#if CasePaths
    #if EXCLUDE_EXPORTS
        public import CasePaths
    #else
        @_exported import CasePaths
    #endif

    extension ColumnGroup where QueryValue: CasePathable & Table {
        public func `is`<V>(
            _ keyPath: KeyPath<Values.TableColumns, TableColumn<Values.QueryOutput, V>>
        ) -> some QueryExpression<Bool> {
            self[dynamicMember: keyPath].isNot(nil)
        }

        public func `is`<V>(
            _ keyPath: KeyPath<Values.TableColumns, ColumnGroup<Values.QueryOutput, V>>
        ) -> some QueryExpression<Bool> {
            self[dynamicMember: keyPath].isNot(nil)
        }

        public func `is`<V>(
            _ keyPath: KeyPath<Values.TableColumns, CaseColumn<Values.QueryOutput, V>>
        ) -> some QueryExpression<Bool> {
            self[dynamicMember: keyPath].isNot(nil)
        }

        public func `is`<V>(
            _ keyPath: KeyPath<Values.TableColumns, CaseColumnGroup<Values.QueryOutput, V>>
        ) -> some QueryExpression<Bool> {
            self[dynamicMember: keyPath].isNot(nil)
        }
    }

    extension OptionalColumnGroup where Values: CasePathable {
        public func `is`<V>(
            _ keyPath: KeyPath<Values.QueryOutput.TableColumns, CaseColumn<Values.QueryOutput, V>>
        ) -> some QueryExpression<Bool> {
            self[dynamicMember: keyPath].isNot(nil)
        }

        public func `is`<V>(
            _ keyPath: KeyPath<
                Values.QueryOutput.TableColumns, CaseColumnGroup<Values.QueryOutput, V>
            >
        ) -> some QueryExpression<Bool> {
            self[dynamicMember: keyPath].isNot(nil)
        }
    }
#endif
