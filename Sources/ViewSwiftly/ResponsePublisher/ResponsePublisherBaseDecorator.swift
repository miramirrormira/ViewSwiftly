//
//  ResponsePublisherDecorator.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine

public class ResponsePublisherBaseDecorator<Response>: ResponsePublisher {
    public typealias ResponseType = Response
    
    let responsePublisher: AnyResponsePublisher<Response>
    
    init(responsePublisher: AnyResponsePublisher<Response>) {
        self.responsePublisher = responsePublisher
    }
    
    public func publisher() async throws -> AnyPublisher<Response, Error> {
        try await responsePublisher.publisher()
    }
}
