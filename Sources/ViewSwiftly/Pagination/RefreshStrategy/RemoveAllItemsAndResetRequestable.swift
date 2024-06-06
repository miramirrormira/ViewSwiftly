//
//  RemoveAllItemsAndResetRequestable.swift
//
//
//  Created by Mira Yang on 6/1/24.
//

import Foundation
import NetSwiftly

public class RemoveAllItemsAndResetRequestable<PageType: Decodable, ItemType: Decodable & Identifiable>: RefreshStrategy {
   
    public let networkConfiguration: NetworkConfiguration
    public let endpoint: Endpoint
    public let paginationQueryStrategy: PaginationQueryStrategy
    public let transform: (PageType) -> [ItemType]
    
    public init(networkConfiguration: NetworkConfiguration,
         endpoint: Endpoint,
         paginationQueryStrategy: PaginationQueryStrategy,
         transform: @escaping (PageType) -> [ItemType]) {
        self.networkConfiguration = networkConfiguration
        self.endpoint = endpoint
        self.paginationQueryStrategy = paginationQueryStrategy
        self.transform = transform
    }
    
    @MainActor
    public func refresh(vm: PaginatedItemsViewModel<ItemType>) {
        let requestable = PaginatedURLRequestCommand(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, transform: transform)
        vm.requestable = AnyRequestable(requestable)
        vm.state.items = []
    }
}
