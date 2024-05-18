//
//  MergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
public protocol MergeItemsStrategy {
    func merge<ItemType, PageType>(vm: PaginatedItemsViewModel<ItemType, PageType>, with newItems: [ItemType]) async
}
