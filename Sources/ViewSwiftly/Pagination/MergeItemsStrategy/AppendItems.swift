//
//  AppendItems.swift
//
//
//  Created by Mira Yang on 5/11/24.
//

import Foundation


public class AppendItems<Item: Decodable & Identifiable, ItemState: Identifiable>: MergeItemsStrategy {
    public init() { }
    @MainActor
    public func merge(vm: PaginatedItemsViewModel<Item, ItemState>, with newItems: [Item]) async throws {
        let itemStates = try await newItems.concurrentMap(vm.itemState)
        vm.state.items.append(contentsOf: itemStates)
    }
}
