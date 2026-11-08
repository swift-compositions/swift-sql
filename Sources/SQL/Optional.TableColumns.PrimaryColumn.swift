public import Byte
public import ISO_9075_Foundation

extension Optional.TableColumns where Wrapped.TableColumns: PrimaryKeyedTableDefinition {
    public struct PrimaryColumn: _TableColumnExpression {
    }
}
