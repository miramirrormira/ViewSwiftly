//
//  PaginatedItemsState.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public struct PaginatedItemsState<ItemType: Identifiable> {
    public var items: [ItemType] = []
    var firstPageLoaded: Bool = false
    var status: LoadingStatus = .notRequested
}
