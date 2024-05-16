//
//  PaginatedItemsViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import NetSwiftly

class PaginatedItemsViewModel<T: Identifiable>: ViewModel {
    
    @MainActor @Published var state = PaginatedItemsState<T>()
    var requestable: AnyRequestable<[T]>
    var firstItemOfLastPage: T.ID?
    var mergeItemsStrategy: MergeItemsStrategy
    
    init(requestable: AnyRequestable<[T]>,
         mergeItemsStrategy: MergeItemsStrategy) {
        self.requestable = requestable
        self.mergeItemsStrategy = mergeItemsStrategy
    }
    
    @MainActor
    func trigger(_ action: PaginatedItemsActions<T>) async {
        switch action {
        case .requestNextPage:
            do {
                guard state.status != .loading else { return }
                state.status = .loading
                let newItems = try await requestable.request()
                state.status = .success
                firstItemOfLastPage = newItems.first?.id
                await mergeItemsStrategy.merge(vm: self, with: newItems)
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
    
    private func shouldRequestNextPage(by item: T) -> Bool {
        item.id == firstItemOfLastPage
    }
}
