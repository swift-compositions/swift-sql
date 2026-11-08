public import ISO_9075_Foundation
public import Time

extension Time.Instant {
    /// An instant stored as text, the literal a `.timestamp` binding writes (`YYYY-MM-DD HH:MM:SS.SSS`), and bound as
    /// that text: the column holds the same bytes as a plain `Time.Instant` column, but the value is text wherever it
    /// travels, as a CloudKit record's String field does. Use it with `@Column(as:)` where a column must stay text.
    public struct ISO8601Representation: QueryRepresentable, Sendable {
        public var queryOutput: Time.Instant

        public init(queryOutput: Time.Instant) {
            self.queryOutput = queryOutput
        }
    }
}

extension Time.Instant.ISO8601Representation: QueryBindable {
    public var queryBinding: ISO_9075.Value {
        do throws(ISO_9075.Value.Failure) {
            return .text(try ISO_9075.Literal.timestamp(queryOutput))
        } catch {
            return .invalid(error)
        }
    }
}

extension Time.Instant.ISO8601Representation: QueryDecodable {
    public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
        guard let text = try decoder.decode(String.self) else { throw .missingRequiredColumn }
        do throws(ISO_9075.Value.Failure) {
            self.init(queryOutput: try ISO_9075.Literal.instant(text))
        } catch {
            throw .dataCorrupted("\(text) as a timestamp")
        }
    }
}
