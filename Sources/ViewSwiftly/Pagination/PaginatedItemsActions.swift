//
//  PaginatedItemsActions.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public enum PaginatedItemsActions<ItemType> {
    case requestNextPage
    case onAppear(item: ItemType)
    case refresh
    case filter(predicate: (ItemType) -> Bool)
}
