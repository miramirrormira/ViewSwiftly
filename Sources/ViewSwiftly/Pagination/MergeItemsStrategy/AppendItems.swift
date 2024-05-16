//
//  AppendItems.swift
//
//
//  Created by Mira Yang on 5/11/24.
//

import Foundation

@MainActor
class AppendItems: MergeItemsStrategy {
    func merge<T>(vm: PaginatedItemsViewModel<T>, with newItems: [T]) async where T : Identifiable {
        vm.state.items.append(contentsOf: newItems)
    }
}
