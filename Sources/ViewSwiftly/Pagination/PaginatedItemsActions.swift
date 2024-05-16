//
//  PaginatedItemsActions.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

enum PaginatedItemsActions<T> {
    case requestNextPage
    case attemptLoadNextPage(item: T)
    case refresh
}
