//
//  FetchItemsStrategySpy.swift
//  
//
//  Created by Mira Yang on 6/23/24.
//

import Foundation
import ViewSwiftly

class FetchedItemsStrategySpy<ItemType>: FetchedItemsStrategy {
    typealias Item = ItemType
    
    var onFetchedItems: ([Item]) async throws -> Void
    
    init(onFetchedItems: @escaping ([Item]) -> Void) {
        self.onFetchedItems = onFetchedItems
    }
    
    func onFetchedItems(_ items: [Item]) async throws {
        try await onFetchedItems(items)
    }
}
