//
//  PaginatedList.swift
//
//
//  Created by Mira Yang on 5/15/24.
//

import Foundation
import SwiftUI

public struct PaginatedList<Item: Identifiable & Decodable, ItemView: View, LoadingView: View, EmptyListView: View, ReachedLastItemView: View>: PaginatedItemsView {
    
    @ObservedObject var viewModel: PaginatedItemsViewModel<Item>
    
    @ViewBuilder var itemView: (Item) -> ItemView
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    var reachedLastItemView: ReachedLastItemView
    var id: String
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    
    var startLoadingOnAppear: Bool
    
    public init(id: String,
                viewModel: PaginatedItemsViewModel<Item>,
                itemView: @escaping (Item) -> ItemView,
                @ViewBuilder loadingView: () -> LoadingView = { ProgressView() },
                @ViewBuilder reachedLastItemView: () -> ReachedLastItemView = { EmptyView() },
                @ViewBuilder emptyListView: () -> EmptyListView = { EmptyView() },
                edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                enableRefresh: Bool = true,
                startLoadingOnAppear: Bool = true) {
        self.id = id
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
        self.startLoadingOnAppear = startLoadingOnAppear
        self.reachedLastItemView = reachedLastItemView()
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
