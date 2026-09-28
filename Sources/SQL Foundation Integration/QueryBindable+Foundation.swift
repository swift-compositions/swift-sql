public import Byte
public import Foundation
public import ISO_9075_Foundation
public import RFC_4122
public import SQL
public import Time

extension Date: QueryBindable {
    public var queryBinding: ISO_9075.Value {
        let seconds = timeIntervalSince1970.rounded(.down)
        return .timestamp(
            Instant(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(seconds),
                nanosecondFraction: Int32(((timeIntervalSince1970 - seconds) * 1_000_000_000).rounded(.down))
            )
        )
    }

    public init(decoder: inout some QueryDecoder) throws {
        let instant = try Instant(decoder: &decoder)
        self.init(
            timeIntervalSince1970: Double(instant.secondsSinceUnixEpoch) + Double(instant.nanosecondFraction) / 1_000_000_000
        )
    }
}

extension UUID: QueryBindable {
    public var queryBinding: ISO_9075.Value { .uuid(RFC_4122.UUID(bytes: uuid)) }

    public init(decoder: inout some QueryDecoder) throws {
        self.init(uuid: try RFC_4122.UUID(decoder: &decoder).bytes)
    }
}

extension Data: QueryBindable {
    public var queryBinding: ISO_9075.Value { .blob(map(Byte.init)) }

    public init(decoder: inout some QueryDecoder) throws {
        self.init(try [Byte](decoder: &decoder).map(\.underlying))
    }
}

extension URL: QueryBindable {
    public var queryBinding: ISO_9075.Value { .text(absoluteString) }

    public init(decoder: inout some QueryDecoder) throws {
        guard let url = Self(string: try String(decoder: &decoder)) else { throw Invalid() }
        self = url
    }

    private struct Invalid: Error {}
}
