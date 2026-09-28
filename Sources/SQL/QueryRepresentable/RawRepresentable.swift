public import ISO_9075_Foundation

public struct _RawRepresentableRawRepresentation<QueryOutput: RawRepresentable>:
    QueryRepresentable
where QueryOutput.RawValue: QueryBindable {
    public var queryOutput: QueryOutput

    public init(queryOutput: QueryOutput) {
        self.queryOutput = queryOutput
    }
}

extension _RawRepresentableRawRepresentation: Equatable where QueryOutput: Equatable {}
extension _RawRepresentableRawRepresentation: Hashable where QueryOutput: Hashable {}
extension _RawRepresentableRawRepresentation: Sendable where QueryOutput: Sendable {}

extension RawRepresentable where RawValue: QueryBindable {
    public typealias RawRepresentation = _RawRepresentableRawRepresentation<Self>
}

extension Optional where Wrapped: RawRepresentable, Wrapped.RawValue: QueryBindable {
    @_documentation(visibility: private)
    public typealias RawRepresentation = _RawRepresentableRawRepresentation<Wrapped>?
}

extension _RawRepresentableRawRepresentation: QueryBindable {
    public var queryBinding: ISO_9075.Value {
        queryOutput.rawValue.queryBinding
    }
}

extension _RawRepresentableRawRepresentation: QueryDecodable {
    public init(decoder: inout some QueryDecoder) throws {
        let rawValue = try QueryOutput.RawValue(decoder: &decoder)
        guard let queryOutput = QueryOutput(rawValue: rawValue)
        else { throw DataCorruptedError() }
        self.init(queryOutput: queryOutput)
    }
}
