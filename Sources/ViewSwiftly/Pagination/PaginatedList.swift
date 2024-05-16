//
//  PaginatedList.swift
//
//
//  Created by Mira Yang on 5/15/24.
//

import Foundation
import SwiftUI

public struct PaginatedList<T: Identifiable, ItemView: View, LoadingView: View, EmptyListView: View>: PaginatedItemsView {

    @ObservedObject var viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>>
    
    @ViewBuilder var itemView: (T) -> ItemView
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    
    public init(viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>>,
         itemView: @escaping (T) -> ItemView,
         @ViewBuilder loadingView: () -> LoadingView,
         @ViewBuilder emptyListView: () -> EmptyListView,
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
