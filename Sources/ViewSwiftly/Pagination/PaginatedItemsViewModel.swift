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
    var requestable: AnyRequestable<PageType>
    var firstItemOfLastPage: ItemType.ID?
    let mergeItemsStrategy: MergeItemsStrategy
    let transform: (PageType) async throws -> [ItemType]
    
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
            guard state.status != .loading else { return }
            state.status = .loading
            do {
                let pageContent = try await requestable.request()
                state.firstPageLoaded = true
                state.status = .success
                let items = try await transform(pageContent)
                firstItemOfLastPage = items.first?.id
                await mergeItemsStrategy.merge(vm: self, with: items)
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
