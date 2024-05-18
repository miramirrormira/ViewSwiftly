//
//  AnyRepository.swift
//  
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
public class AnyRepository<T>: Repository {
    
    public typealias Content = T
    private let wrappedGetContent: () async throws -> T?
    
    public init<V: Repository>(_ repository: V) where V.Content == Content {
        self.wrappedGetContent = repository.getContent
    }
    
    public func getContent() async throws -> T? {
        try await wrappedGetContent()
    }
}
