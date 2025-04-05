//
//  PaginatedItemsState.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public struct PaginatedItemsState<Item> {
    public var items: [Item] = []
    public var firstPageLoaded: Bool = false
    public var status: LoadingStatus = .notRequested
}
