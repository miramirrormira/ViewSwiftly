//
//  PaginatedItemsState.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation

public struct PaginatedItemsState<ItemStateType> {
    public var items: [ItemStateType] = []
    public var firstPageLoaded: Bool = false
    public var status: LoadingStatus = .notRequested
}
