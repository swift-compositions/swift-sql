public import RFC_4122
public import Time_Primitive

extension SQL {

    public protocol Row: Sendable {

        func string(_ column: String) throws(SQL.Error) -> String
        func int(_ column: String) throws(SQL.Error) -> Int
        func int64(_ column: String) throws(SQL.Error) -> Int64
        func double(_ column: String) throws(SQL.Error) -> Double
        func bool(_ column: String) throws(SQL.Error) -> Bool
        func uuid(_ column: String) throws(SQL.Error) -> RFC_4122.UUID
        func timestamp(_ column: String) throws(SQL.Error) -> Instant
        func bytes(_ column: String) throws(SQL.Error) -> [UInt8]

        func stringIfPresent(_ column: String) throws(SQL.Error) -> String?
        func intIfPresent(_ column: String) throws(SQL.Error) -> Int?
        func int64IfPresent(_ column: String) throws(SQL.Error) -> Int64?
        func doubleIfPresent(_ column: String) throws(SQL.Error) -> Double?
        func boolIfPresent(_ column: String) throws(SQL.Error) -> Bool?
        func uuidIfPresent(_ column: String) throws(SQL.Error) -> RFC_4122.UUID?
        func timestampIfPresent(_ column: String) throws(SQL.Error) -> Instant?
        func bytesIfPresent(_ column: String) throws(SQL.Error) -> [UInt8]?

        func string(at index: Int) throws(SQL.Error) -> String
        func int(at index: Int) throws(SQL.Error) -> Int
        func int64(at index: Int) throws(SQL.Error) -> Int64
        func double(at index: Int) throws(SQL.Error) -> Double
        func bool(at index: Int) throws(SQL.Error) -> Bool
        func uuid(at index: Int) throws(SQL.Error) -> RFC_4122.UUID
        func timestamp(at index: Int) throws(SQL.Error) -> Instant
        func bytes(at index: Int) throws(SQL.Error) -> [UInt8]

        func stringIfPresent(at index: Int) throws(SQL.Error) -> String?
        func intIfPresent(at index: Int) throws(SQL.Error) -> Int?
        func int64IfPresent(at index: Int) throws(SQL.Error) -> Int64?
        func doubleIfPresent(at index: Int) throws(SQL.Error) -> Double?
        func boolIfPresent(at index: Int) throws(SQL.Error) -> Bool?
        func uuidIfPresent(at index: Int) throws(SQL.Error) -> RFC_4122.UUID?
        func timestampIfPresent(at index: Int) throws(SQL.Error) -> Instant?
        func bytesIfPresent(at index: Int) throws(SQL.Error) -> [UInt8]?
    }
}
