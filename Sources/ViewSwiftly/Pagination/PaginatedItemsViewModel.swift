//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly
import Combine

public class PaginatedItemsViewModel<ItemType: Identifiable, PageType: Decodable>: ViewModel {
    
    @MainActor @Published public var state = PaginatedItemsState<ItemType>()
    public var requestable: AnyRequestable<PageType>
    public var firstItemOfLastPage: ItemType.ID?
    public var lastItemOfLastPage: ItemType.ID?
    public let mergeItemsStrategy: MergeItemsStrategy
    public let refreshStrategy: RefreshStrategy?
    public let transform: (PageType) async throws -> [ItemType]
    public let onFetchItems: (([ItemType]) async throws -> Void)?
    public let scrollDirection: ScrollDirection
    
    public enum ScrollDirection {
        case up, down
    }
    
    public init(requestable: AnyRequestable<PageType>,
                mergeItemsStrategy: MergeItemsStrategy = AppendItems(),
                refreshStrategy: RefreshStrategy? = nil,
                onFetchItems: (([ItemType]) async throws -> Void)? = nil,
                scrollDirection: ScrollDirection = .down,
                transform: @escaping (PageType) async throws -> [ItemType]) {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
        self.refreshStrategy = refreshStrategy
        self.transform = transform
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
                let pageContent = try await requestable.request()
                state.firstPageLoaded = true
                state.status = .success
                let items = try await transform(pageContent)
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
    convenience init(networkConfiguration: NetworkConfiguration,
                     endpoint: Endpoint,
                     paginationQueryStrategy: PaginationQueryStrategy,
                     transform: @escaping (PageType) async throws -> [ItemType],
                     mergeItemsStrategy: MergeItemsStrategy = AppendItems(),
                     refreshStrategy: RefreshStrategy? = nil,
                     onFetchItems: (([ItemType]) async throws -> Void)? = nil) {
        let requestable = PaginatedURLRequestCommand<PageType>.init(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy)
        self.init(requestable: AnyRequestable(requestable), mergeItemsStrategy: mergeItemsStrategy, refreshStrategy: refreshStrategy, onFetchItems: onFetchItems, transform: transform)
    }
}
