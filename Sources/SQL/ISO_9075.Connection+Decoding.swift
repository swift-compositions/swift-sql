public import ISO_9075_Call_Level_Interface

extension ISO_9075.Connection {
    @inlinable
    @usableFromInline
    func fetchAll<Value>(
        _ statement: ISO_9075.Fragment,
        decoding: (inout QueryRowDecoder<Row>) throws(QueryDecodingError) -> Value
    ) throws(ISO_9075.Error) -> [Value] {
        try fetchAll(statement) { row throws(ISO_9075.Error) in
            var decoder = QueryRowDecoder(row: row)
            do throws(QueryDecodingError) {
                return try decoding(&decoder)
            } catch {
                throw .decoding("\(error)")
            }
        }
    }
}
