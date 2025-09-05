//
//  AnyRefreshStrategy.swift
//  
//
//  Created by Mira Yang on 6/6/24.
//

import Foundation

public class AnyRefreshStrategy<Item: Decodable & Identifiable>: RefreshStrategy {
    
    public typealias ItemType = Item
    
    let wrappedRefresh: (PaginatedItemsViewModel<Item>) async throws -> Void
    
    public init<V: RefreshStrategy>(_ strategy: V) where V.ItemType == Item {
        wrappedRefresh = strategy.refresh(vm:)
    }
    
    public func refresh(vm: PaginatedItemsViewModel<Item>) async throws {
        try await wrappedRefresh(vm)
    }
    
}
