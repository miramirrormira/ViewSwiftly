//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly
import Combine

public class PaginatedItemsViewModel<ItemType: Identifiable & Decodable>: ViewModel {
    
    @MainActor @Published public var state = PaginatedItemsState<ItemType>()
    public var requestable: AnyRequestable<[ItemType]>
    public var firstItemOfLastPage: ItemType.ID?
    public var lastItemOfLastPage: ItemType.ID?
    public var mergeItemsStrategy: MergeItemsStrategy
    public var refreshStrategy: AnyRefreshStrategy<ItemType>?
    public var onFetchItems: (([ItemType]) async throws -> Void)?
    public var scrollDirection: ScrollDirection
    
    public enum ScrollDirection {
        case up, down
    }
    
    public init(requestable: AnyRequestable<[ItemType]>,
                mergeItemsStrategy: MergeItemsStrategy = AppendItems(),
                refreshStrategy: AnyRefreshStrategy<ItemType>? = nil,
                onFetchItems: (([ItemType]) async throws -> Void)? = nil,
                scrollDirection: ScrollDirection = .down) {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
        self.refreshStrategy = refreshStrategy
        self.onFetchItems = onFetchItems
        self.scrollDirection = scrollDirection
    }
    
    @MainActor
    public func trigger(_ action: PaginatedItemsActions<ItemType>) async {
        switch action {
        case .requestNextPage:
            guard state.status != .loading else { return }
            state.status = .loading
            do {
                let items = try await requestable.request()
                state.firstPageLoaded = true
                state.status = .success
                firstItemOfLastPage = items.first?.id
                lastItemOfLastPage = items.last?.id
                await mergeItemsStrategy.merge(vm: self, with: items)
                try await onFetchItems?(items)
            } catch {
                state.status = .error(error)
            }
        case .refresh:
            refreshStrategy?.refresh(vm: self)
        case .onAppear(let item):
            if shouldRequestNextPage(by: item) {
                await trigger(.requestNextPage)
            }
        case .filter(predicate: let predicate):
            state.items = state.items.filter(predicate)
        }
    }
    
    func shouldRequestNextPage(by item: ItemType) -> Bool {
        switch scrollDirection {
        case .up:
            lastItemOfLastPage == nil || item.id == lastItemOfLastPage!
        case .down:
            firstItemOfLastPage == nil || item.id == firstItemOfLastPage!
        }
    }
}

public extension PaginatedItemsViewModel {
    convenience init<PageType: Decodable>(networkConfiguration: NetworkConfiguration,
                                          endpoint: Endpoint,
                                          paginationQueryStrategy: PaginationQueryStrategy,
                                          mergeItemsStrategy: MergeItemsStrategy = AppendItems(),
                                          refreshStrategy: AnyRefreshStrategy<ItemType>? = nil,
                                          onFetchItems: (([ItemType]) async throws -> Void)? = nil,
                                          transform: @escaping (PageType) -> [ItemType]) {
        
        let requestable = PaginatedURLRequestCommand<PageType, ItemType>(networkConfiguration: networkConfiguration,
                                                                         endpoint: endpoint,
                                                                         paginationQueryStrategy: paginationQueryStrategy,
                                                                         transform: transform)
        
        let anyRequestable = AnyRequestable<[ItemType]>(requestable)
        self.init(requestable: anyRequestable, mergeItemsStrategy: mergeItemsStrategy, refreshStrategy: refreshStrategy, onFetchItems: onFetchItems)
    }
}
