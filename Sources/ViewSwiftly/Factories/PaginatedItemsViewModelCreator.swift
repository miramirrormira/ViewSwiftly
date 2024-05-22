//
//  File.swift
//  
//
//  Created by Mira Yang on 5/21/24.
//

import Foundation
import NetSwiftly

public func makePaginatedItemsViewModel<ItemType, PageType: Decodable>(networkConfiguration: NetworkConfiguration,
                                                            endpoint: Endpoint,
                                                            paginationQueryStrategy: PaginationQueryStrategy,
                                                                       transform: @escaping (PageType) async throws -> [ItemType]) -> PaginatedItemsViewModel<ItemType, PageType> {
    let paginatedURLRequestCommand: PaginatedURLRequestCommand<PageType> = makePaginatedURLRequestCommand(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy)
    return PaginatedItemsViewModel(requestable: AnyRequestable(paginatedURLRequestCommand), transform: transform)
}
