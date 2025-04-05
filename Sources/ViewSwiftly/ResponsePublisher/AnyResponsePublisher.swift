//
//  AnyResponsePublisher.swift
//  
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine

public class AnyResponsePublisher<Response>: ResponsePublisher {
    
    public typealias ResponseType = Response
    let wrappedPublisher: () async throws -> AnyPublisher<Response, Error>
    
    public init<R: ResponsePublisher>(_ responsePublisher: R) where R.ResponseType == Response {
        self.wrappedPublisher = responsePublisher.publisher
    }
    
    public func publisher() async throws -> AnyPublisher<Response, Error> {
        try await wrappedPublisher()
    }
}
