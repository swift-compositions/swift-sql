public import Byte
public import ISO_9075_Foundation

public protocol _OptionalPromotable<_Optionalized> {
    associatedtype _Optionalized: _OptionalProtocol = Self?
}
