public import Foundation
public import SQL

extension CollationOrder {
    public init(_ comparisonResult: ComparisonResult) {
        switch comparisonResult {
        case .orderedAscending: self = .ascending
        case .orderedDescending: self = .descending
        default: self = .same
        }
    }
}
