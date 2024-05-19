//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly

public class PaginatedItemsViewModel<ItemType: Identifiable, PageType>: ViewModel {
    
    @MainActor @Published public var state = PaginatedItemsState<ItemType>()
    private var requestable: AnyRequestable<PageType>
    private var firstItemOfLastPage: ItemType.ID?
    private let mergeItemsStrategy: MergeItemsStrategy
    private let transform: (PageType) async throws -> [ItemType]
    
    public init(requestable: AnyRequestable<PageType>,
                mergeItemsStrategy: MergeItemsStrategy = AppendItems(),
                transform: @escaping (PageType) async throws -> [ItemType]) {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
        self.transform = transform
    }
    
    @MainActor
    public func trigger(_ action: PaginatedItemsActions<ItemType>) async {
        switch action {
        case .requestNextPage:
            do {
                guard state.status != .loading else { return }
                state.status = .loading
                let pageContent = try await requestable.request()
                let newItems = try await transform(pageContent)
                state.status = .success
                firstItemOfLastPage = newItems.first?.id
                await mergeItemsStrategy.merge(vm: self, with: newItems)
                state.firstPageLoaded = true
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
    
    private func shouldRequestNextPage(by item: ItemType) -> Bool {
        firstItemOfLastPage == nil || item.id == firstItemOfLastPage!
    }
}
