#if Tagged
    public import Tagged
    public import ISO_9075_Foundation

    public protocol _TaggedProtocol<Untagged> {
        associatedtype Untagged
    }

    extension Tagged: _TaggedProtocol where Underlying: Copyable & Escapable {
        public typealias Untagged = Underlying
    }

    extension QueryExpression where QueryValue: _TaggedProtocol {
        /// The expression with its phantom tag removed.
        ///
        /// Use this projection to compare a tagged column with an expression or value of its
        /// underlying type. It does not change the generated SQL.
        public var untag: some QueryExpression<QueryValue.Untagged> {
            SQLQueryExpression(queryFragment)
        }
    }

    extension Tagged: _OptionalPromotable
    where Tag: ~Copyable & ~Escapable, Underlying: _OptionalPromotable {}

    extension Tagged: QueryBindable where Tag: ~Copyable & ~Escapable, Underlying: QueryBindable {
        public var queryBinding: ISO_9075.Value {
            underlying.queryBinding
        }
    }

    extension Tagged: QueryDecodable where Tag: ~Copyable & ~Escapable, Underlying: QueryDecodable {
        public init(decoder: inout some QueryDecoder) throws(QueryDecodingError) {
            self.init(_unchecked: try Underlying(decoder: &decoder))
        }
    }

    extension Tagged: QueryExpression where Tag: ~Copyable & ~Escapable, Underlying: QueryExpression {
        public var queryFragment: ISO_9075.Fragment {
            underlying.queryFragment
        }
    }

    extension Tagged: QueryRepresentable
    where Tag: ~Copyable & ~Escapable, Underlying: QueryRepresentable {
        public typealias QueryOutput = Tagged<Tag, Underlying.QueryOutput>

        public var queryOutput: QueryOutput {
            QueryOutput(_unchecked: underlying.queryOutput)
        }

        public init(queryOutput: QueryOutput) {
            self.init(_unchecked: Underlying(queryOutput: queryOutput.underlying))
        }

        public static func queryFragment(decoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
            Underlying.queryFragment(decoding: queryFragment)
        }

        public static func _queryFragment(jsonEncoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
            Underlying._queryFragment(jsonEncoding: queryFragment)
        }

        public static func _queryFragment(jsonDecoding queryFragment: ISO_9075.Fragment) -> ISO_9075.Fragment {
            Underlying._queryFragment(jsonDecoding: queryFragment)
        }

    }
#endif
