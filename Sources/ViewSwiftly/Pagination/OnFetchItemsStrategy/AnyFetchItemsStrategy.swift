//
//  AnyFetchItemsStrategy.swift
//
//
//  Created by Mira Yang on 6/20/24.
//

import Foundation

public class AnyFetchItemsStrategy<Item>: FetchItemsStrategy {
    
    public typealias ItemType = Item
    
    let wrappedOnFetchItems: ([Item]) async throws -> Void
    
    public init<V: FetchItemsStrategy>(_ strategy: V) where V.ItemType == ItemType {
        self.wrappedOnFetchItems = strategy.onFetchItems(_:)
    }
    
    public func onFetchItems(_ items: [Item]) async throws {
        try await wrappedOnFetchItems(items)
    }
}
