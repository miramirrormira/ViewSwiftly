//
//  AnyFetchItemsStrategy.swift
//
//
//  Created by Mira Yang on 6/20/24.
//

import Foundation

public class AnyFetchItemsStrategy<ItemType>: FetchItemsStrategy {
    
    public typealias Item = ItemType
    
    let wrappedOnFetchItems: ([Item]) async throws -> Void
    
    public init<V: FetchItemsStrategy>(_ strategy: V) where V.Item == ItemType {
        self.wrappedOnFetchItems = strategy.onFetchItems(_:)
    }
    
    public func onFetchItems(_ items: [ItemType]) async throws {
        try await wrappedOnFetchItems(items)
    }
}
