extension SQL {

    public enum Error: Swift.Error, Sendable {

        case connection(String)

        case execution(String)

        case decoding(String)

        case transaction(String)

        case migration(String)

        case binding(String)
    }
}
