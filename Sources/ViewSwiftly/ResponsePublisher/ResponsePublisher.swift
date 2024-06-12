//
//  ResponsePublisher.swift
//
//
//  Created by Mira Yang on 6/11/24.
//

import Foundation
import Combine

public protocol ResponsePublisher {
    associatedtype Response
    func publisher() async throws -> AnyPublisher<Response, Error>
}
