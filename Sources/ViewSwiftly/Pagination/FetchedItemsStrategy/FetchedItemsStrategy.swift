//
//  OnFetchItemsStrategy.swift
//
//
//  Created by Mira Yang on 6/20/24.
//

import Foundation

public protocol FetchedItemsStrategy {
    associatedtype ItemType
    func onFetchedItems(_ items: [ItemType]) async throws
}

public extension FetchedItemsStrategy {
    func eraseToAnyFetchedItemsStrategy() -> AnyFetchedItemsStrategy<ItemType> {
        return AnyFetchedItemsStrategy(self)
    }
}
