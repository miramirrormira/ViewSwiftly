//
//  RemoveAllItemsAndResetRequestable.swift
//
//
//  Created by Mira Yang on 6/1/24.
//

import Foundation
import NetSwiftly

class RemoveAllItemsAndResetRequestable: RefreshStrategy {
    let networkConfiguration: NetworkConfiguration
    let endpoint: Endpoint
    let paginationQueryStrategy: PaginationQueryStrategy
    init(networkConfiguration: NetworkConfiguration,
         endpoint: Endpoint,
         paginationQueryStrategy: PaginationQueryStrategy) {
        self.networkConfiguration = networkConfiguration
        self.endpoint = endpoint
        self.paginationQueryStrategy = paginationQueryStrategy
    }
    
    @MainActor
    func refresh<ItemType>(vm: PaginatedItemsViewModel<ItemType>) {
        let requestable = PaginatedURLRequestCommand<[ItemType]>.init(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy)
        vm.requestable = AnyRequestable(requestable)
        vm.state.items = []
    }
}
