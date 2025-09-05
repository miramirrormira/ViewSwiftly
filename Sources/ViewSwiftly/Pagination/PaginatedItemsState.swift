//
//  PaginatedItemsState.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import SwiftUI

public struct PaginatedItemsState<Item: Identifiable> {
    public var items: [Item] = []
    public var firstPageLoaded: Bool = false
    public var status: LoadingStatus = .notRequested
    public var reachedLastItem = false
    public var scrollPositionId: Item.ID? = nil
    public var scrollPositionAnchorUnitPoint: UnitPoint? = nil
    public var debounceTimeInMilliseconds: UInt64 = 0
    public var itemsIndexMap: [Item.ID: Int] = [:]
    public var scrollOffset: CGRect = .zero
    
    public init() {}
    
    public init (
        items: [Item] = [],
        firstPageLoaded: Bool = false,
        status: LoadingStatus = .notRequested,
        reachedLastItem: Bool = false,
        scrollPositionId: Item.ID? = nil,
        scrollPositionAnchorUnitPoint: UnitPoint? = nil,
        debounceTimeInMilliseconds: UInt64 = 0
    ) {
        self.items = items
        self.firstPageLoaded = firstPageLoaded
        self.status = status
        self.reachedLastItem = reachedLastItem
        self.scrollPositionId = scrollPositionId
        self.scrollPositionAnchorUnitPoint = scrollPositionAnchorUnitPoint
        self.debounceTimeInMilliseconds = debounceTimeInMilliseconds
    }
}
