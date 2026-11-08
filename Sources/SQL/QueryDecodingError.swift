public import Byte
public import RFC_4122
public import Time

public enum QueryDecodingError: Swift.Error, Hashable, Sendable {
    case missingRequiredColumn
    case typeMismatch(expected: String)
    case dataCorrupted(String)
    case overflow(String)
}
