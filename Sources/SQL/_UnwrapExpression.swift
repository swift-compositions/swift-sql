public import Byte
public import ISO_9075_Foundation

public struct _UnwrapExpression<Base: QueryExpression>: QueryExpression
where Base.QueryValue: _OptionalProtocol {
    let base: Base
}
