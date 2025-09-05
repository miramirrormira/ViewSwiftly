//
//  ResponsePublisher.swift
//
//
//  Created by Mira Yang on 6/23/24.
//

import Foundation
import ViewSwiftly
import Combine

class ResponsePublisherStub<V>: ResponsePublisher {
    
    typealias Response = V
    
    var returnValue: V?
    var error: Error?
    
    init(returning: V) {
        self.returnValue = returning
    }
    
    init(error: Error) {
        self.error = error
    }
    
    func publisher() async throws -> AnyPublisher<V, Error> {
        
        if let returnValue = self.returnValue {
            return Just(returnValue).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        
        if let error = error {
            return Fail(error: error).eraseToAnyPublisher()
        }
        
        fatalError()
    }
}
