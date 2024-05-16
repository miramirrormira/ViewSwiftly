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
    public func merge<T>(vm: PaginatedItemsViewModel<T>, with newItems: [T]) async where T : Identifiable {
        vm.state.items.append(contentsOf: newItems)
    }
}
