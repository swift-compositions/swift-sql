#if PostgreSQLStandardIntegration

    internal import Byte_Primitives
    internal import RFC_4122
    internal import SQL
    internal import Structured_Queries_Primitives
    internal import Time_Primitive

    extension SQL {

        struct RowDecoder: QueryDecoder {
            let row: any SQL.Row
            var index: Int = 0

            init(row: any SQL.Row) {
                self.row = row
            }
        }

    }

    extension SQL.RowDecoder {
        mutating func decode(_ columnType: [Byte].Type) throws -> [Byte]? {
            defer { index += 1 }
            return try row.bytesIfPresent(at: index)?.map { Byte($0) }
        }

        mutating func decode(_ columnType: Double.Type) throws -> Double? {
            defer { index += 1 }
            return try row.doubleIfPresent(at: index)
        }

        mutating func decode(_ columnType: Int64.Type) throws -> Int64? {
            defer { index += 1 }
            return try row.int64IfPresent(at: index)
        }

        mutating func decode(_ columnType: UInt64.Type) throws -> UInt64? {
            defer { index += 1 }
            return try row.int64IfPresent(at: index).map { UInt64(bitPattern: $0) }
        }

        mutating func decode(_ columnType: String.Type) throws -> String? {
            defer { index += 1 }
            return try row.stringIfPresent(at: index)
        }

        mutating func decode(_ columnType: Bool.Type) throws -> Bool? {
            defer { index += 1 }
            return try row.boolIfPresent(at: index)
        }

        mutating func decode(_ columnType: Int.Type) throws -> Int? {
            defer { index += 1 }
            return try row.intIfPresent(at: index)
        }

        mutating func decode(_ columnType: Instant.Type) throws -> Instant? {
            defer { index += 1 }
            return try row.timestampIfPresent(at: index)
        }

        mutating func decode(_ columnType: QueryBinding.UUID.Type) throws -> QueryBinding.UUID? {
            defer { index += 1 }
            guard let uuid = try row.uuidIfPresent(at: index) else { return nil }
            return QueryBinding.UUID(bytes: uuid.byteArray.map { Byte($0) })
        }
    }

#endif
