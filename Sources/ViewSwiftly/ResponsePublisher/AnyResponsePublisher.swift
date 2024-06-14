//
//  File.swift
//  
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine

public class AnyResponsePublisher<V>: ResponsePublisher {
    
    public typealias Response = V
    
    let wrappedPublisher: () async throws -> AnyPublisher<Response, Error>
    
    public init<R: ResponsePublisher>(_ responsePublisher: R) where R.Response == V {
        self.wrappedPublisher = responsePublisher.publisher
    }
    
    public func publisher() async throws -> AnyPublisher<V, Error> {
        try await wrappedPublisher()
    }
}
