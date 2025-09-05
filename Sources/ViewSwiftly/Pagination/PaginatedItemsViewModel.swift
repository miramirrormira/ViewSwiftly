//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly
import Combine

@MainActor
public class PaginatedItemsViewModel<Item: Identifiable & Decodable>: ViewModel {
    
    @Published public var state: PaginatedItemsState<Item>
    public var requestable: AnyRequestable<[Item]>
    public var firstItemOfLastPage: Item.ID?
    public var lastItemOfLastPage: Item.ID?
    public var refreshStrategy: AnyRefreshStrategy<Item>?
    public var fetchedItemsStrategy: AnyFetchedItemsStrategy<Item>?
    public var scrollDirection: ScrollDirection
    let label: String
    
    public enum ScrollDirection {
        case up, down
    }
    
    public init(state: PaginatedItemsState<Item> = PaginatedItemsState<Item>(),
                requestable: AnyRequestable<[Item]>,
                refreshStrategy: AnyRefreshStrategy<Item>? = nil,
                fetchedItemsStrategy: AnyFetchedItemsStrategy<Item>? = nil,
                scrollDirection: ScrollDirection = .up,
                label: String = "") {
        self.state = state
        self.requestable = requestable
        self.refreshStrategy = refreshStrategy
        self.fetchedItemsStrategy = fetchedItemsStrategy
        self.scrollDirection = scrollDirection
        self.label = label
    }
    
    public func trigger(_ action: PaginatedItemsActions<Item>) async {
        switch action {
        case .requestNextPage:
            guard state.status != .loading && state.reachedLastItem == false else {
                Logger.debug("\(label) already loading next page")
                return
            }
            state.status = .loading
            do {
                let items = try await requestable.request()
                Logger.debug("\(type(of: Item.self)) \(label) loaded \(items.count) new \(Item.Type.self)s.")
                state.firstPageLoaded = true
                state.status = .success
                if items.isEmpty {
                    state.reachedLastItem = true
                }
                for item in items {
                    state.items.append(item)
                    state.itemsIndexMap[item.id] = state.items.count - 1
                }
                firstItemOfLastPage = state.items.first?.id
                lastItemOfLastPage = state.items.last?.id
                try await fetchedItemsStrategy?.onFetchedItems(items)
            } catch {
                state.status = .failure(error)
                Logger.error("\(error.localizedDescription)")
            }
        case .refresh:
            do {
                try await refreshStrategy?.refresh(vm: self)
            } catch {
                Logger.error(error.localizedDescription)
            }
        case .onAppear(let item):
            if shouldRequestNextPage(by: item) {
                await trigger(.requestNextPage)
            }
        case .filter(predicate: let predicate):
            state.items = state.items.filter(predicate)
        }
    }
    
    func shouldRequestNextPage(by item: Item) -> Bool {
        switch scrollDirection {
        case .up:
            lastItemOfLastPage == nil || item.id == lastItemOfLastPage!
        case .down:
            firstItemOfLastPage == nil || item.id == firstItemOfLastPage!
        }
    }
    
    deinit {
        Logger.debug("\(Item.Type.self), \(label)")
    }
}

public extension PaginatedItemsViewModel {
    convenience init<Page: Decodable>(networkConfiguration: NetworkConfiguration,
                                      endpoint: Endpoint,
                                      paginationQueryStrategy: PaginationQueryStrategy,
                                      refreshStrategy: AnyRefreshStrategy<Item>? = nil,
                                      fetchedItemsStrategy: AnyFetchedItemsStrategy<Item>? = nil,
                                      transform: @escaping (Page) -> [Item],
                                      label: String = "") {
        let requestable = PaginatedURLRequestRequest<Page, Item>(networkConfiguration: networkConfiguration,
                                                                 endpoint: endpoint,
                                                                 paginationQueryStrategy: paginationQueryStrategy,
                                                                 transform: transform)
        let anyRequestable = AnyRequestable<[Item]>(requestable)
        self.init(requestable: anyRequestable, refreshStrategy: refreshStrategy, fetchedItemsStrategy: fetchedItemsStrategy, label: label)
    }
    
    convenience init(initialItems: [Item],
                     requestable: AnyRequestable<[Item]>,
                     refreshStrategy: AnyRefreshStrategy<Item>? = nil,
                     fetchedItemsStrategy: AnyFetchedItemsStrategy<Item>? = nil,
                     scrollDirection: ScrollDirection = .up,
                     label: String = "") {
        self.init(requestable: requestable, refreshStrategy: refreshStrategy, fetchedItemsStrategy: fetchedItemsStrategy, label: label)
        self.state = PaginatedItemsState(items: initialItems)
        Task {
            try await self.fetchedItemsStrategy?.onFetchedItems(initialItems)
        }
    }
}
