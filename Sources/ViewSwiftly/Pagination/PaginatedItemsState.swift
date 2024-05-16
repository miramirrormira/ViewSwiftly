//
//  PaginatedItemsState.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public struct PaginatedItemsState<T: Identifiable> {
    var items: [T] = []
    var firstPageLoaded: Bool = false
    var status: Status = .notRequested
    
    enum Status {
        case notRequested
        case loading
        case success
        case error(Error)
    }
}

extension PaginatedItemsState.Status: Equatable {
    static func == (lhs: PaginatedItemsState<T>.Status, rhs: PaginatedItemsState<T>.Status) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.notRequested, .notRequested):
            return true
        case (.success, .success):
            return true
        case (.error(let errorLhs), .error(let errorRhs)):
            return errorLhs.localizedDescription == errorRhs.localizedDescription
        default:
            return false
        }
    }
}
