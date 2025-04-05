//
//  AppendItems.swift
//
//
//  Created by Mira Yang on 5/11/24.
//

import Foundation


public class AppendItems<Item: Decodable & Identifiable>: MergeItemsStrategy {
    public typealias ItemType = Item
    public init() { }
    @MainActor
    public func merge(vm: PaginatedItemsViewModel<Item>, with newItems: [Item]) async throws {
        vm.state.items.append(contentsOf: newItems)
    }
}
