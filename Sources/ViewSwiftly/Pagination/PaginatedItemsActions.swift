//
//  PaginatedItemsActions.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public enum PaginatedItemsActions<ItemType> {
    case requestNextPage
    case attemptLoadNextPage(item: ItemType)
    case refresh
}
