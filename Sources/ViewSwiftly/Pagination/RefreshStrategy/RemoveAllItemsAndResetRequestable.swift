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
    func refresh<ItemType, PageType>(vm: PaginatedItemsViewModel<ItemType, PageType>) where ItemType : Identifiable, PageType : Decodable {
        let requestable = PaginatedURLRequestCommand<PageType>.init(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy)
        vm.requestable = AnyRequestable(requestable)
        vm.state.items = []
    }
}
