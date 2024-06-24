//
//  PaginatedItemsActions.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public enum PaginatedItemsActions<ItemStateType> {
    case requestNextPage
    case onAppear(item: ItemStateType)
    case refresh
    case filter(predicate: (ItemStateType) -> Bool)
}
