//
//  RemoveAllItemsAndReuseRequestable.swift
//  ViewSwiftly
//
//  Created by Curtis Colly on 6/19/25.
//

public class RemoveAllItemsAndReuseRequestable<Item: Decodable & Identifiable>: RefreshStrategy {
    public typealias ItemType = Item
    
    init() {}
    
    @MainActor
    public func refresh(vm: PaginatedItemsViewModel<Item>) {
        let requestable = vm.requestable
        
    }
    
    
}
