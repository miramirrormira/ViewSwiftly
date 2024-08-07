//
//  AnyMergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 8/6/24.
//

import Foundation

final public class AnyMergeItemsStrategy<Item: Decodable & Identifiable, ItemState: Identifiable>: MergeItemsStrategy {
    
    public typealias ItemType = Item
    public typealias ItemStateType = ItemState
    
    let wrappedMerge: (PaginatedItemsViewModel<Item, ItemState>, [Item]) async throws -> Void
    
    public init<V: MergeItemsStrategy>(_ strategy: V) where V.ItemType == Item, V.ItemStateType == ItemState {
        self.wrappedMerge = strategy.merge(vm:with:)
    }
    
    public func merge(vm: PaginatedItemsViewModel<Item, ItemState>, with newItems: [Item]) async throws {
        try await wrappedMerge(vm, newItems)
    }
}
