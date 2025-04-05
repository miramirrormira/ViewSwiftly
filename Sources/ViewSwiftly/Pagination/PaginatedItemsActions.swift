//
//  PaginatedItemsActions.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public enum PaginatedItemsActions<Item> {
    case requestNextPage
    case onAppear(item: Item)
    case refresh
    case filter(predicate: (Item) -> Bool)
}
