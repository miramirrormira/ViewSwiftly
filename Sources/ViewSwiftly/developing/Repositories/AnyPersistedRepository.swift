//
//  File.swift
//  
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation

public class AnyPersistedRepository<T>: PersistedRepository {
    public typealias Content = T
    
    private let wrappedSave: (T) async throws -> Void
    private let wrappedGetContent: () async throws -> T?
    
    public init<V: PersistedRepository>(_ writableRepository: V) where V.Content == Content {
        self.wrappedSave = writableRepository.save(_:)
        self.wrappedGetContent = writableRepository.getContent
    }
    
    public func save(_ content: T) async throws {
        try await wrappedSave(content)
    }
    
    public func getContent() async throws -> T? {
        try await wrappedGetContent()
    }
}
