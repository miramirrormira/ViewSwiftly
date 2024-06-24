//
//  AnyRefreshStrategy.swift
//  
//
//  Created by Mira Yang on 6/6/24.
//

import Foundation

public class AnyRefreshStrategy<T: Decodable & Identifiable, S: Identifiable>: RefreshStrategy {
    
    public typealias ItemStateType = S
    public typealias ItemType = T
    
    let wrappedRefresh: (PaginatedItemsViewModel<T, S>) -> Void
    
    public init<V: RefreshStrategy>(_ strategy: V) where V.ItemType == T, V.ItemStateType == S {
        wrappedRefresh = strategy.refresh(vm:)
    }
    
    public func refresh(vm: PaginatedItemsViewModel<T, S>) {
        wrappedRefresh(vm)
    }
    
}
