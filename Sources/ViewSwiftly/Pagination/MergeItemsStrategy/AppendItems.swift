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
    public func merge<ItemType>(vm: PaginatedItemsViewModel<ItemType>, with newItems: [ItemType]) async {
        vm.state.items.append(contentsOf: newItems)
    }
}
