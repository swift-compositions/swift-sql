public import Byte
public import ISO_9075_Foundation


extension Optional: Table, PartialSelectStatement, Statement where Wrapped: Table {
    @dynamicMemberLookup
    public struct TableColumns: TableDefinition {
        public typealias QueryValue = Optional

        public static var allColumns: [Column<Optional>] {
            Wrapped.TableColumns.allColumns.map(\.optional)
        }

        public static var writableColumns: [Column<Optional>] {
            Wrapped.TableColumns.writableColumns.map(\.optional)
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, TableColumn<Wrapped, Member>>
        ) -> TableColumn<Optional, Member?> {
            let column = Wrapped.columns[keyPath: keyPath]
            return TableColumn<Optional, Member?>(
                column.name,
                keyPath: \.[member: \Member.self, column: column.keyPath]
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, GeneratedColumn<Wrapped, Member>>
        ) -> GeneratedColumn<Optional, Member?> {
            let column = Wrapped.columns[keyPath: keyPath]
            return GeneratedColumn<Optional, Member?>(
                column.name,
                keyPath: \.[member: \Member.self, column: column.keyPath]
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, ColumnGroup<Wrapped, Member>>
        ) -> OptionalColumnGroup<Optional, Member> {
            let column = Wrapped.columns[keyPath: keyPath]
            return OptionalColumnGroup(
                base: ColumnGroup<Optional, Member?>(
                    column.groupName,
                    keyPath: \.[member: \Member.self, column: column.keyPath]
                )
            )
        }

        public subscript<Member>(
            dynamicMember keyPath: KeyPath<
                Wrapped.TableColumns, OptionalColumnGroup<Wrapped, Member>
            >
        ) -> OptionalColumnGroup<Optional, Member> {
            let column = Wrapped.columns[keyPath: keyPath]
            return OptionalColumnGroup(
                base: ColumnGroup<Optional, Member?>(
                    column.groupName,
                    keyPath: \.[flattenedMember: \Member.self, column: column.keyPath]
                )
            )
        }

        #if CasePaths
            public subscript<Member>(
                dynamicMember keyPath: KeyPath<Wrapped.TableColumns, CaseColumn<Wrapped, Member>>
            ) -> TableColumn<Optional, Member??> {
                let column = Wrapped.columns[keyPath: keyPath].base
                return TableColumn<Optional, Member??>(
                    column.name,
                    keyPath: \.[member: \Member?.self, column: column.keyPath]
                )
            }

            public subscript<Member>(
                dynamicMember keyPath: KeyPath<
                    Wrapped.TableColumns, CaseColumnGroup<Wrapped, Member>
                >
            ) -> ColumnGroup<Optional, Member??> {
                let column = Wrapped.columns[keyPath: keyPath].base
                return ColumnGroup<Optional, Member??>(
                    column.groupName,
                    keyPath: \.[member: \Member?.self, column: column.keyPath]
                )
            }
        #endif

        public subscript<Member: QueryExpression>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, Member>
        ) -> some QueryExpression<Member.QueryValue?> {
            Member?.some(Wrapped.columns[keyPath: keyPath])
        }

        @_disfavoredOverload
        public subscript<QueryValue>(
            dynamicMember keyPath: KeyPath<Wrapped.TableColumns, some QueryExpression<QueryValue?>>
        ) -> some QueryExpression<QueryValue?> {
            Wrapped.columns[keyPath: keyPath]
        }
    }
}
