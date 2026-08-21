public import RFC_4122
public import Time_Primitive

extension SQL {

    public enum Value: Sendable, Hashable {
        case text(String)
        case int(Int)
        case int64(Int64)
        case double(Double)
        case bool(Bool)
        case uuid(RFC_4122.UUID)
        case timestamp(Instant)

        case blob([UInt8])

        case jsonb([UInt8])

        case decimal(String)

        indirect case array([SQL.Value])
        case null
    }
}
