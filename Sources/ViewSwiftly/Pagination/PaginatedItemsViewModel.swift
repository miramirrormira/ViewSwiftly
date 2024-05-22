//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly

public class PaginatedItemsViewModel<ItemType: Identifiable, PageType: Decodable>: ViewModel {
    
    @MainActor @Published public var state = PaginatedItemsState<ItemType>()
    var requestable: AnyRequestable<PageType>
    var firstItemOfLastPage: ItemType.ID?
    let mergeItemsStrategy: MergeItemsStrategy
    let transform: (PageType) async throws -> [ItemType]
    let onFetchItems: (([ItemType]) async throws -> Void)?
    
    public init(requestable: AnyRequestable<PageType>,
                mergeItemsStrategy: MergeItemsStrategy = AppendItems(),
                transform: @escaping (PageType) async throws -> [ItemType],
                onFetchItems: (([ItemType]) async throws -> Void)? = nil) {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
        self.transform = transform
        self.onFetchItems = onFetchItems
    }
    
    @MainActor
    public func trigger(_ action: PaginatedItemsActions<ItemType>) async {
        switch action {
        case .requestNextPage:
            guard state.status != .loading else { return }
            state.status = .loading
            do {
                let pageContent = try await requestable.request()
                state.firstPageLoaded = true
                state.status = .success
                let items = try await transform(pageContent)
                firstItemOfLastPage = items.first?.id
                await mergeItemsStrategy.merge(vm: self, with: items)
                try await onFetchItems?(items)
            } catch {
                state.status = .error(error)
            }
        case .refresh:
            break
        case .attemptLoadNextPage(let item):
            if shouldRequestNextPage(by: item) {
                await trigger(.requestNextPage)
            }
        }
    }
    
    func shouldRequestNextPage(by item: ItemType) -> Bool {
        firstItemOfLastPage == nil || item.id == firstItemOfLastPage!
    }
}

public extension PaginatedItemsViewModel {
    convenience init(networkConfiguration: NetworkConfiguration,
                     endpoint: Endpoint,
                     paginationQueryStrategy: PaginationQueryStrategy,
                     transform: @escaping (PageType) async throws -> [ItemType],
                     mergeItemsStrategy: MergeItemsStrategy = AppendItems(),
                     onFetchItems: (([ItemType]) async throws -> Void)? = nil) {
        let requestable = PaginatedURLRequestCommand<PageType>.init(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy)
        self.init(requestable: AnyRequestable(requestable), mergeItemsStrategy: mergeItemsStrategy, transform: transform, onFetchItems: onFetchItems)
    }
}
