//
//  PaginatedList.swift
//
//
//  Created by Mira Yang on 5/15/24.
//

import Foundation
import SwiftUI

public struct PaginatedList<Item: Identifiable, ItemView: View, LoadingView: View, EmptyListView: View>: PaginatedItemsView {
    
    @ObservedObject var viewModel: AnyViewModel<PaginatedItemsState<Item>, PaginatedItemsActions<Item>>
    
    @ViewBuilder var itemView: (Item) -> ItemView
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    
    public init(viewModel: AnyViewModel<PaginatedItemsState<Item>, PaginatedItemsActions<Item>>,
                itemView: @escaping (Item) -> ItemView,
                @ViewBuilder loadingView: () -> LoadingView = { EmptyView() },
                @ViewBuilder emptyListView: () -> EmptyListView = { EmptyView() },
                edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                enableRefresh: Bool = true) {
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
    }
    
    public var body: some View {
        content
    }
    
    @ViewBuilder
    func listView() -> some View {
        List {
            items
                .padding(edgeInsets)
        }
        .listStyle(.inset)
        .scrollIndicators(.hidden)
        .if(enableRefresh) { view in
            view.refreshable {
                await viewModel.trigger(.refresh)
            }
        }
    }
}
