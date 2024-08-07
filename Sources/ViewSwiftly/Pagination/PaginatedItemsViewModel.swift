//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly
import Combine

public class PaginatedItemsViewModel<ItemType: Identifiable & Decodable, ItemStateType: Identifiable>: ViewModel {
    
    @MainActor @Published public var state = PaginatedItemsState<ItemStateType>()
    public var requestable: AnyRequestable<[ItemType]>
    public var firstItemOfLastPage: ItemStateType.ID?
    public var lastItemOfLastPage: ItemStateType.ID?
    public var mergeItemsStrategy: AnyMergeItemsStrategy<ItemType, ItemStateType>
    public var refreshStrategy: AnyRefreshStrategy<ItemType, ItemStateType>?
    public var fetchItemsStrategy: AnyFetchItemsStrategy<ItemType>?
    public var scrollDirection: ScrollDirection
    public let itemState: (ItemType) async throws -> ItemStateType
    let label: String
    
    public enum ScrollDirection {
        case up, down
    }
    
    public init(requestable: AnyRequestable<[ItemType]>,
                mergeItemsStrategy: AnyMergeItemsStrategy<ItemType, ItemStateType> = AnyMergeItemsStrategy<ItemType, ItemStateType>(AppendItems()),
                refreshStrategy: AnyRefreshStrategy<ItemType, ItemStateType>? = nil,
                fetchItemsStrategy: AnyFetchItemsStrategy<ItemType>? = nil,
                scrollDirection: ScrollDirection = .down,
                label: String = "",
                itemState: @escaping (ItemType) async throws -> ItemStateType) {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
        self.refreshStrategy = refreshStrategy
        self.fetchItemsStrategy = fetchItemsStrategy
        self.scrollDirection = scrollDirection
        self.label = label
        self.itemState = itemState
    }
    
    public init(requestable: AnyRequestable<[ItemType]>,
                mergeItemsStrategy: AnyMergeItemsStrategy<ItemType, ItemStateType> = AnyMergeItemsStrategy<ItemType, ItemStateType>(AppendItems()),
                refreshStrategy: AnyRefreshStrategy<ItemType, ItemStateType>? = nil,
                fetchItemsStrategy: AnyFetchItemsStrategy<ItemType>? = nil,
                scrollDirection: ScrollDirection = .down,
                label: String = "") where ItemType == ItemStateType, ItemStateType: Identifiable {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
        self.refreshStrategy = refreshStrategy
        self.fetchItemsStrategy = fetchItemsStrategy
        self.scrollDirection = scrollDirection
        self.label = label
        self.itemState = { $0 }
    }
    
    @MainActor
    public func trigger(_ action: PaginatedItemsActions<ItemStateType>) async {
        switch action {
        case .requestNextPage:
            guard state.status != .loading else { return }
            state.status = .loading
            do {
                let items = try await requestable.request()
                state.firstPageLoaded = true
                state.status = .success
                
                try await mergeItemsStrategy.merge(vm: self, with: items)
                firstItemOfLastPage = state.items.first?.id
                lastItemOfLastPage = state.items.last?.id
                try await fetchItemsStrategy?.onFetchItems(items)
            } catch {
                state.status = .failure(error)
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
    
    func shouldRequestNextPage(by item: ItemStateType) -> Bool {
        switch scrollDirection {
        case .up:
            lastItemOfLastPage == nil || item.id == lastItemOfLastPage!
        case .down:
            firstItemOfLastPage == nil || item.id == firstItemOfLastPage!
        }
    }
    
    deinit {
        Logger.debug("\(ItemType.Type.self), \(label)")
    }
}

public extension PaginatedItemsViewModel {
    convenience init<PageType: Decodable>(networkConfiguration: NetworkConfiguration,
                                          endpoint: Endpoint,
                                          paginationQueryStrategy: PaginationQueryStrategy,
                                          mergeItemsStrategy: AnyMergeItemsStrategy<ItemType, ItemStateType> = .init(AppendItems()),
                                          refreshStrategy: AnyRefreshStrategy<ItemType, ItemStateType>? = nil,
                                          fetchItemsStrategy: AnyFetchItemsStrategy<ItemType>? = nil,
                                          transform: @escaping (PageType) -> [ItemType],
                                          label: String = "",
                                          itemState: @escaping (ItemType) async throws -> ItemStateType) {
        
        let requestable = PaginatedURLRequestCommand<PageType, ItemType>(networkConfiguration: networkConfiguration,
                                                                         endpoint: endpoint,
                                                                         paginationQueryStrategy: paginationQueryStrategy,
                                                                         transform: transform)
        
        let anyRequestable = AnyRequestable<[ItemType]>(requestable)
        self.init(requestable: anyRequestable, mergeItemsStrategy: mergeItemsStrategy, refreshStrategy: refreshStrategy, fetchItemsStrategy: fetchItemsStrategy, label: label, itemState: itemState)
    }
    
    convenience init<PageType: Decodable>(networkConfiguration: NetworkConfiguration,
                                          endpoint: Endpoint,
                                          paginationQueryStrategy: PaginationQueryStrategy,
                                          mergeItemsStrategy: AnyMergeItemsStrategy<ItemType, ItemStateType> = .init(AppendItems()),
                                          refreshStrategy: AnyRefreshStrategy<ItemType, ItemStateType>? = nil,
                                          fetchItemsStrategy: AnyFetchItemsStrategy<ItemType>? = nil,
                                          transform: @escaping (PageType) -> [ItemType],
                                          label: String = "") where ItemType == ItemStateType {
        
        let requestable = PaginatedURLRequestCommand<PageType, ItemType>(networkConfiguration: networkConfiguration,
                                                                         endpoint: endpoint,
                                                                         paginationQueryStrategy: paginationQueryStrategy,
                                                                         transform: transform)
        
        let anyRequestable = AnyRequestable<[ItemType]>(requestable)
        self.init(requestable: anyRequestable, mergeItemsStrategy: mergeItemsStrategy, refreshStrategy: refreshStrategy, fetchItemsStrategy: fetchItemsStrategy, label: label)
    }
}
