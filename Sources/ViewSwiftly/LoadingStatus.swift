//
//  LoadingStatus.swift
//  
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
public enum LoadingStatus {
    case notRequested
    case loading
    case success
    case failure(Error)
    
    var error: Error? {
        switch self {
        case .failure(let error):
            return error
        default: return nil
        }
    }
}

extension LoadingStatus: Equatable {
    public static func == (lhs: LoadingStatus, rhs: LoadingStatus) -> Bool {
        switch (lhs, rhs) {
        case (.loading, .loading):
            return true
        case (.notRequested, .notRequested):
            return true
        case (.success, .success):
            return true
        case (.failure(let errorLhs), .failure(let errorRhs)):
            return errorLhs.localizedDescription == errorRhs.localizedDescription
        default:
            return false
        }
    }
}
