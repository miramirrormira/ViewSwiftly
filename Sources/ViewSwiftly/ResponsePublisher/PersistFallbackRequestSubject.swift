//
//  PersistFallbackRequestSubject.swift
//
//
//  Created by Mira Yang on 6/11/24.
//

import Foundation
import Combine
import NetSwiftly

class PersistFallbackRequestSubject<T>: ResponsePublisher {
    
    typealias Response = T
    
    let networkingRequest: AnyRequestable<T>
    let persistedRequest: AnyRequestable<T>
    var networkingRequestResponded: Bool = false
    
    enum DataSource {
        case persisted
        case network
    }
    
    init(networkingRequest: AnyRequestable<T>,
         persistedRequest: AnyRequestable<T>) {
        self.networkingRequest = networkingRequest
        self.persistedRequest = persistedRequest
    }
    
    func publisher() -> AnyPublisher<T, Error> {
        let persistedPub = Future<(T, DataSource), Error> { promise in
            Task {
                do {
                    let result = try await self.persistedRequest.request()
                    promise(Result.success((result, .persisted)))
                } catch {
                    promise(Result.failure(error))
                }
            }
        }.eraseToAnyPublisher()
        
        let networkPub = Future<(T, DataSource), Error> { promise in
            Task {
                do {
                    let result = try await self.networkingRequest.request()
                    promise(Result.success((result, .network)))
                } catch {
                    promise(Result.failure(error))
                }
            }
        }.eraseToAnyPublisher()
        
        return persistedPub
            .merge(with: networkPub)
            .filter { [weak self] _ in
                guard let strongSelf = self else {
                    return false
                }
                return strongSelf.networkingRequestResponded == false
            }
            .map({ result in
                if result.1 == .network {
                    self.networkingRequestResponded = true
                }
                return result.0
            })
//            .map({ value in
//                value.0
//            })
            .eraseToAnyPublisher()
    }
    
}
