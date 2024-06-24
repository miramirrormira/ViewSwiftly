//
//  MergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
public protocol MergeItemsStrategy {
    func merge<ItemType, ItemStateType>(vm: PaginatedItemsViewModel<ItemType, ItemStateType>, with newItems: [ItemType]) async throws
}
