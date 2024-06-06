//
//  AnyRefreshStrategy.swift
//  
//
//  Created by Mira Yang on 6/6/24.
//

import Foundation

public class AnyRefreshStrategy<T: Decodable & Identifiable>: RefreshStrategy {
    
    public typealias ItemType = T
    let wrappedRefresh: (PaginatedItemsViewModel<T>) -> Void
    
    public init<V: RefreshStrategy>(_ strategy: V) where V.ItemType == T {
        wrappedRefresh = strategy.refresh(vm:)
    }
    
    public func refresh(vm: PaginatedItemsViewModel<T>) {
        wrappedRefresh(vm)
    }
    
}
