//
//  MergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
public protocol MergeItemsStrategy {
    func merge<ItemType>(vm: PaginatedItemsViewModel<ItemType>, with newItems: [ItemType]) async
}
