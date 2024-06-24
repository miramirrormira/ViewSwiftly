//
//  FetchItemsStrategySpy.swift
//  
//
//  Created by Mira Yang on 6/23/24.
//

import Foundation
import ViewSwiftly

class FetchItemsStrategySpy<ItemType>: FetchItemsStrategy {
    typealias Item = ItemType
    
    var onFetchItems: ([Item]) async throws -> Void
    
    init(onFetchItems: @escaping ([Item]) -> Void) {
        self.onFetchItems = onFetchItems
    }
    
    func onFetchItems(_ items: [Item]) async throws {
        try await onFetchItems(items)
    }
}
