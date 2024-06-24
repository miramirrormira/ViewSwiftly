//
//  PaginatedItemsState.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public struct PaginatedItemsState<ItemStateType> {
    public var items: [ItemStateType] = []
    var firstPageLoaded: Bool = false
    var status: LoadingStatus = .notRequested
}
