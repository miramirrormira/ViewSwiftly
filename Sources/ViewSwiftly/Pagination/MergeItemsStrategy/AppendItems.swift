//
//  AppendItems.swift
//
//
//  Created by Mira Yang on 5/11/24.
//

import Foundation


public class AppendItems: MergeItemsStrategy {
    
    public init() { }
    
    @MainActor
    public func merge<ItemType, ItemStateType>(vm: PaginatedItemsViewModel<ItemType, ItemStateType>, with newItems: [ItemType]) async throws {
        
        let itemStates = try await newItems.concurrentMap(vm.itemState)
        vm.state.items.append(contentsOf: itemStates)
    }
}
