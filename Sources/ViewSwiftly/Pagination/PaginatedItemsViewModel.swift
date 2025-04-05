//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly
import Combine

public class PaginatedItemsViewModel<Item: Identifiable & Decodable>: ViewModel {
    
    @MainActor @Published public var state = PaginatedItemsState<Item>()
    public var requestable: AnyRequestable<[Item]>
    public var firstItemOfLastPage: Item.ID?
    public var lastItemOfLastPage: Item.ID?
    public var mergeItemsStrategy: AnyMergeItemsStrategy<Item>
    public var refreshStrategy: AnyRefreshStrategy<Item>?
    public var fetchItemsStrategy: AnyFetchItemsStrategy<Item>?
    public var scrollDirection: ScrollDirection
    let label: String
    
    public enum ScrollDirection {
        case up, down
    }
    
    public init(requestable: AnyRequestable<[Item]>,
                mergeItemsStrategy: AnyMergeItemsStrategy<Item> = AnyMergeItemsStrategy<Item>(AppendItems()),
                refreshStrategy: AnyRefreshStrategy<Item>? = nil,
                fetchItemsStrategy: AnyFetchItemsStrategy<Item>? = nil,
                scrollDirection: ScrollDirection = .down,
                label: String = "") {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
        self.refreshStrategy = refreshStrategy
        self.fetchItemsStrategy = fetchItemsStrategy
        self.scrollDirection = scrollDirection
        self.label = label
    }
    
    @MainActor
    public func trigger(_ action: PaginatedItemsActions<Item>) async {
        switch action {
        case .requestNextPage:
            guard state.status != .loading else { return }
            state.status = .loading
            do {
                let items = try await requestable.request()
                
                #if DEBUG
                Logger.info("\(label) loaded new items: \(items)")
                #endif
                
                state.firstPageLoaded = true
                state.status = .success
                
                try await mergeItemsStrategy.merge(vm: self, with: items)
                firstItemOfLastPage = state.items.first?.id
                lastItemOfLastPage = state.items.last?.id
                try await fetchItemsStrategy?.onFetchItems(items)
            } catch {
                state.status = .failure(error)
                #if DEBUG
                Logger.error("\(error.localizedDescription)")
                #endif
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
    
    func shouldRequestNextPage(by item: Item) -> Bool {
        switch scrollDirection {
        case .up:
            lastItemOfLastPage == nil || item.id == lastItemOfLastPage!
        case .down:
            firstItemOfLastPage == nil || item.id == firstItemOfLastPage!
        }
    }
    
    #if DEBUG
    deinit {
        Logger.debug("\(Item.Type.self), \(label)")
    }
    #endif
}

public extension PaginatedItemsViewModel {
    convenience init<Page: Decodable>(networkConfiguration: NetworkConfiguration,
                                          endpoint: Endpoint,
                                          paginationQueryStrategy: PaginationQueryStrategy,
                                          mergeItemsStrategy: AnyMergeItemsStrategy<Item> = AnyMergeItemsStrategy<Item>(AppendItems()),
                                          refreshStrategy: AnyRefreshStrategy<Item>? = nil,
                                          fetchItemsStrategy: AnyFetchItemsStrategy<Item>? = nil,
                                          transform: @escaping (Page) -> [Item],
                                          label: String = "") {
        
        let requestable = PaginatedURLRequestCommand<Page, Item>(networkConfiguration: networkConfiguration,
                                                                         endpoint: endpoint,
                                                                         paginationQueryStrategy: paginationQueryStrategy,
                                                                         transform: transform)
        
        let anyRequestable = AnyRequestable<[Item]>(requestable)
        self.init(requestable: anyRequestable, mergeItemsStrategy: mergeItemsStrategy, refreshStrategy: refreshStrategy, fetchItemsStrategy: fetchItemsStrategy, label: label)
    }
}
