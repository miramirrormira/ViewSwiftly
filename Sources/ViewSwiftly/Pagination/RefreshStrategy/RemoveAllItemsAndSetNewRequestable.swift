//
//  RemoveAllItemsAndResetRequestable.swift
//
//
//  Created by Mira Yang on 6/1/24.
//

import Foundation
import NetSwiftly

public class RemoveAllItemsAndSetNewRequestable<Page: Decodable, Item: Decodable & Identifiable>: RefreshStrategy {
    
    public typealias ItemType = Item
    
    public let networkConfiguration: NetworkConfiguration
    public let endpoint: Endpoint
    public let paginationQueryStrategy: PaginationQueryStrategy
    public let transform: (Page) -> [Item]
    
    public init(networkConfiguration: NetworkConfiguration,
                endpoint: Endpoint,
                paginationQueryStrategy: PaginationQueryStrategy,
                transform: @escaping (Page) -> [Item]) {
        self.networkConfiguration = networkConfiguration
        self.endpoint = endpoint
        self.paginationQueryStrategy = paginationQueryStrategy
        self.transform = transform
    }
    
    @MainActor
    public func refresh(vm: PaginatedItemsViewModel<Item>) {
        let requestable = PaginatedURLRequestRequest(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, transform: transform)
        vm.requestable = AnyRequestable(requestable)
        vm.state.items = []
    }
}
