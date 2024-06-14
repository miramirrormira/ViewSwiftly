//
//  FallbackPublisherDecorator.swift
//
//
//  Created by Mira Yang on 6/11/24.
//

import Foundation
import Combine
import NetSwiftly

class FallbackPublisherDecorator<T>: ResponsePublisherDecorator<T> {
    
    typealias Response = T
    
    let fallbackPublisher: AnyResponsePublisher<T>
    var networkingRequestResponded: Bool = false
    
    enum DataSource {
        case fallback
        case response
    }
    
    init(fallbackPublisher: AnyResponsePublisher<T>, responsePublisher: AnyResponsePublisher<T>) {
        self.fallbackPublisher = fallbackPublisher
        super.init(responsePublisher: responsePublisher)
    }
    
    convenience init(fallbackRequestable: AnyRequestable<T>, responseRequestable: AnyRequestable<T>) {
        let fallbackPublisher = AnyResponsePublisher(RequestResponseSubject(requestable: fallbackRequestable))
        let responsePublisher = AnyResponsePublisher(RequestResponseSubject(requestable: responseRequestable))
        self.init(fallbackPublisher: fallbackPublisher, responsePublisher: responsePublisher)
    }
    
    override func publisher() async throws -> AnyPublisher<T, Error> {
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
