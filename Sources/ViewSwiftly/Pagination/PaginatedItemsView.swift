//
//  PaginatedItemsView.swift
//
//
//  Created by Mira Yang on 5/14/24.
//

import Foundation
import SwiftUI

protocol PaginatedItemsView: View {
    
    associatedtype ItemView: View
    associatedtype PageView: View
    associatedtype LoadingView: View
    associatedtype EmptyListView: View
    associatedtype T: Identifiable
    
    var itemView: (T) -> ItemView { get set }
    var loadingView: LoadingView { get set }
    var emptyListView: EmptyListView { get set }
    func listView() -> PageView
    
    var viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>> { get set }
    var enableRefresh: Bool { get }
}

extension PaginatedItemsView {
    @ViewBuilder
    var items: some View {
        ForEach(viewModel.state.items) { item in
            itemView(item)
                .onAppear {
                    Task(priority: .background) {
                        await viewModel.trigger(.attemptLoadNextPage(item: item))
                    }
                }
        }
        if viewModel.state.status == .loading {
            ProgressView().frame(maxWidth: .infinity)
        }
    }
    
    @ViewBuilder
    var content: some View {
        if viewModel.state.firstPageLoaded == false {
            loadingView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.state.items.isEmpty {
            ScrollView {
                emptyListView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .if(enableRefresh) { view in
                        view.modifier(RefreshableModifier())
                    }
            }
            .if(enableRefresh) { view in
                view.refreshable {
                    await viewModel.trigger(.refresh)
                }
            }
        } else {
            listView()
        }
    }
}
