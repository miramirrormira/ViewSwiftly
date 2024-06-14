//
//  ResponsePublisherDecorator.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine

public class ResponsePublisherDecorator<V>: ResponsePublisher {
    public typealias Response = V
    
    let responsePublisher: AnyResponsePublisher<V>
    
    init(responsePublisher: AnyResponsePublisher<V>) {
        self.responsePublisher = responsePublisher
    }
    
    public func publisher() async throws -> AnyPublisher<V, Error> {
        try await responsePublisher.publisher()
    }
}
