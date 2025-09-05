//
//  RequestResponseSubject.swift
//  
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import NetSwiftly
import Combine

public class RequestResponseSubject<Response>: ResponsePublisher {
    
    public typealias ResponseType = Response
    
    let requestable: AnyRequestable<Response>
    
    public init(requestable: AnyRequestable<Response>) {
        self.requestable = requestable
    }
    
    public func publisher() -> AnyPublisher<Response, Error> {
        Future { promise in
            Task {
                do {
                    let result = try await self.requestable.request()
                    promise(Result.success(result))
                } catch {
                    promise(Result.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
