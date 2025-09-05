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
    associatedtype ListView: View
    associatedtype LoadingView: View
    associatedtype EmptyListView: View
    associatedtype ItemType: Identifiable & Decodable
    associatedtype ReachedLastItemView: View
    
    var itemView: (ItemType) -> ItemView { get set }
    var loadingView: LoadingView { get set }
    var emptyListView: EmptyListView { get set }
    var reachedLastItemView: ReachedLastItemView { get set }
    func listView() -> ListView
    
    var viewModel: PaginatedItemsViewModel<ItemType> { get }
    var enableRefresh: Bool { get }
    var startLoadingOnAppear: Bool { get }
    var id: String { get }
}

extension PaginatedItemsView {
    
    @ViewBuilder @MainActor
    var content: some View {
        Group {
            if viewModel.state.firstPageLoaded == false {
                loadingView
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.state.items.isEmpty {
                ScrollView {
                    emptyListView
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .coordinateSpace(.named(id))
        .onAppear {
            if startLoadingOnAppear {
                Task {
                    await viewModel.trigger(.requestNextPage)
                }
            }
        }
    }
    
    @ViewBuilder @MainActor
    var items: some View {
        ForEach(viewModel.state.items) { item in
            itemView(item)
                .onAppear {
                    Task(priority: .background) {
                        await viewModel.trigger(.onAppear(item: item))
                    }
                }
        }
        if viewModel.state.status == .loading {
            ProgressView().frame(maxWidth: .infinity)
        }
        if viewModel.state.reachedLastItem {
            reachedLastItemView
        }
    }
}
