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
    public func merge<ItemType, PageType>(vm: PaginatedItemsViewModel<ItemType, PageType>, with newItems: [ItemType]) async where ItemType : Identifiable {
        vm.state.items.append(contentsOf: newItems)
    }
}
