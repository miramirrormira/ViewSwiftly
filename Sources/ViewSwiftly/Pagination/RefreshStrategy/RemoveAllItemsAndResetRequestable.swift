//
//  RemoveAllItemsAndResetRequestable.swift
//
//
//  Created by Mira Yang on 6/1/24.
//

import Foundation
import NetSwiftly

class RemoveAllItemsAndResetRequestable<PageType: Decodable, ItemType: Decodable & Identifiable>: RefreshStrategy {
   
    let networkConfiguration: NetworkConfiguration
    let endpoint: Endpoint
    let paginationQueryStrategy: PaginationQueryStrategy
    let transform: (PageType) -> [ItemType]
    
    init(networkConfiguration: NetworkConfiguration,
         endpoint: Endpoint,
         paginationQueryStrategy: PaginationQueryStrategy,
         transform: @escaping (PageType) -> [ItemType]) {
        self.networkConfiguration = networkConfiguration
        self.endpoint = endpoint
        self.paginationQueryStrategy = paginationQueryStrategy
        self.transform = transform
    }
    
    @MainActor
    func refresh(vm: PaginatedItemsViewModel<ItemType>) {
        let requestable = PaginatedURLRequestCommand(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, transform: transform)
        vm.requestable = AnyRequestable(requestable)
        vm.state.items = []
    }
}
