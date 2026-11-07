public import Byte
public import ISO_9075_Foundation


extension Optional.TableColumns: PrimaryKeyedTableDefinition
where Wrapped.TableColumns: PrimaryKeyedTableDefinition {
    public struct PrimaryColumn: _TableColumnExpression {
        public typealias Root = Optional

        public typealias Value = Wrapped.PrimaryKey?

        public var _names: [String] {
            Wrapped.columns.primaryKey._names
        }

        public var defaultValue: Wrapped.PrimaryKey.QueryOutput?? {
            Wrapped.columns.primaryKey.defaultValue
        }

        public var keyPath: KeyPath<Wrapped?, Wrapped.PrimaryKey.QueryOutput?> {
            \.[member: \Wrapped.PrimaryKey.self, column: Wrapped.columns.primaryKey.keyPath]
        }

        public var queryFragment: ISO_9075.Fragment {
            Wrapped.columns.primaryKey.queryFragment
        }
    }
}
