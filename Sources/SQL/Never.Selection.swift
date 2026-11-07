public import ISO_9075_Foundation

public import ISO_9075_Foundation

extension Never: Table {
    public struct Selection: TableExpression {
        public typealias QueryValue = Never

        public var allColumns: [ISO_9075.Fragment] { [] }
    }
}
