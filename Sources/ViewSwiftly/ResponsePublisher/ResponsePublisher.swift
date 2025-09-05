//
//  ResponsePublisher.swift
//
//
//  Created by Mira Yang on 6/11/24.
//

import Foundation
import Combine

public protocol ResponsePublisher {
    associatedtype ResponseType
    func publisher() async throws -> AnyPublisher<ResponseType, Error>
}

public extension ResponsePublisher {
    func eraseToAnyResponsePublisher() -> AnyResponsePublisher<ResponseType> {
        return AnyResponsePublisher(self)
    }
}
