//
//  LoadingStatus.swift
//  
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
enum LoadingStatus {
    case notRequested
    case loading
    case success
    case error(Error)
}

extension LoadingStatus: Equatable {
    static func == (lhs: LoadingStatus, rhs: LoadingStatus) -> Bool {
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
