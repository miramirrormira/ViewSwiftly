//
//  AnyMergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 8/6/24.
//

import Foundation

final public class AnyMergeItemsStrategy<Item: Decodable & Identifiable>: MergeItemsStrategy {
    
    public typealias ItemType = Item
    
    let wrappedMerge: (PaginatedItemsViewModel<Item>, [Item]) async throws -> Void
    
    public init<V: MergeItemsStrategy>(_ strategy: V) where V.ItemType == Item {
        self.wrappedMerge = strategy.merge(vm:with:)
    }
    
    public func merge(vm: PaginatedItemsViewModel<Item>, with newItems: [Item]) async throws {
        try await wrappedMerge(vm, newItems)
    }
}
