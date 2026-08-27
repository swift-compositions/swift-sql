#if PostgreSQLStandardIntegration

    internal import Byte
    public import PostgreSQL_Standard
    internal import RFC_4122
    public import SQL

    extension SQL.Query {

        public init(_ statement: some Statement) throws(SQL.Error) {
            let prepared = statement.query.prepare { "$\($0)" }
            var values: [SQL.Value] = []
            values.reserveCapacity(prepared.bindings.count)
            for binding in prepared.bindings {
                values.append(try Self.value(from: binding))
            }
            self.init(sql: prepared.sql, bindings: values)
        }

        static func value(from binding: QueryBinding) throws(SQL.Error) -> SQL.Value {
            switch binding {
            case .text(let text): return .text(text)
            case .int(let int): return .int64(int)
            case .double(let double): return .double(double)
            case .bool(let bool): return .bool(bool)
            case .null: return .null
            case .uuid(let uuid): return .uuid(try Self.identifier(from: uuid))
            case .date(let instant): return .timestamp(instant)
            case .blob(let bytes): return .blob(bytes.map(\.underlying))
            case .jsonb(let bytes): return .jsonb(bytes.map(\.underlying))

            case .decimal(let digits): return .decimal(digits)
            case .boolArray(let values): return .array(values.map { .bool($0) })
            case .stringArray(let values): return .array(values.map { .text($0) })
            case .intArray(let values): return .array(values.map { .int($0) })
            case .int16Array(let values): return .array(values.map { .int64(Int64($0)) })
            case .int32Array(let values): return .array(values.map { .int64(Int64($0)) })
            case .int64Array(let values): return .array(values.map { .int64($0) })
            case .floatArray(let values): return .array(values.map { .double(Double($0)) })
            case .doubleArray(let values): return .array(values.map { .double($0) })
            case .dateArray(let values): return .array(values.map { .timestamp($0) })

            case .uuidArray(let values):
                var identifiers: [SQL.Value] = []
                identifiers.reserveCapacity(values.count)
                for value in values { identifiers.append(.uuid(try Self.identifier(from: value))) }
                return .array(identifiers)

            case .genericArray(let values):
                var elements: [SQL.Value] = []
                elements.reserveCapacity(values.count)
                for value in values { elements.append(try Self.value(from: value)) }
                return .array(elements)

            case .invalid: throw SQL.Error.binding("binding is invalid")
            }
        }

        private static func identifier(
            from uuid: QueryBinding.UUID
        ) throws(SQL.Error) -> RFC_4122.UUID {
            do throws(RFC_4122.UUID.Error) {
                return try RFC_4122.UUID(uuid.bytes.map(\.underlying))
            } catch {
                throw SQL.Error.binding("uuid binding is not exactly 16 bytes")
            }
        }
    }

#endif
