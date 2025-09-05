//
//  FallbackPublisherDecorator.swift
//
//
//  Created by Mira Yang on 6/11/24.
//

import Foundation
import Combine
import NetSwiftly

class FallbackPublisherDecorator<Response>: ResponsePublisherBaseDecorator<Response> {
    
    let fallbackPublisher: AnyResponsePublisher<Response>
    var networkingRequestResponded: Bool = false
    
    enum DataSource {
        case fallback
        case response
    }
    
    init(fallbackPublisher: AnyResponsePublisher<Response>, responsePublisher: AnyResponsePublisher<Response>) {
        self.fallbackPublisher = fallbackPublisher
        super.init(responsePublisher: responsePublisher)
    }
    
    convenience init(fallbackRequestable: AnyRequestable<Response>, responseRequestable: AnyRequestable<Response>) {
        let fallbackPublisher = AnyResponsePublisher(RequestResponseSubject(requestable: fallbackRequestable))
        let responsePublisher = AnyResponsePublisher(RequestResponseSubject(requestable: responseRequestable))
        self.init(fallbackPublisher: fallbackPublisher, responsePublisher: responsePublisher)
    }
    
    override func publisher() async throws -> AnyPublisher<Response, Error> {
        let responsePub = try await super.publisher().map { response in
            return (response, DataSource.response)
        }
        let fallbackPub = try await fallbackPublisher.publisher().map { response in
            return (response, DataSource.fallback)
        }
        return fallbackPub
            .merge(with: responsePub)
            .filter { [weak self] _ in
                guard let strongSelf = self else {
                    return false
                }
                return strongSelf.networkingRequestResponded == false
            }
            .map({ result in
                if result.1 == .response {
                    self.networkingRequestResponded = true
                }
                return result.0
            })
            .eraseToAnyPublisher()
    }
}
