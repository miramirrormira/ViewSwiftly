//
//  AnyFetchedItemsStrategy.swift
//
//
//  Created by Mira Yang on 6/20/24.
//

import Foundation

public class AnyFetchedItemsStrategy<Item>: FetchedItemsStrategy {
    
    public typealias ItemType = Item
    
    let wrappedOnFetchedItems: ([Item]) async throws -> Void
    
    public init<V: FetchedItemsStrategy>(_ strategy: V) where V.ItemType == ItemType {
        self.wrappedOnFetchedItems = strategy.onFetchedItems(_:)
    }
    
    public func onFetchedItems(_ items: [Item]) async throws {
        try await wrappedOnFetchedItems(items)
    }
}
