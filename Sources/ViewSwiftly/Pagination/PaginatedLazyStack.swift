//
//  PaginatedLazyStack.swift
//
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
import SwiftUI

public struct PaginatedLazyStack<Item: Identifiable, ItemView: View, LoadingView: View, EmptyListView: View>: PaginatedItemsView {
    
    @ObservedObject var viewModel: AnyViewModel<PaginatedItemsState<Item>, PaginatedItemsActions<Item>>
    
    @ViewBuilder var itemView: (Item) -> ItemView
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    let axis: Axis.Set
    let verticalAlignment: VerticalAlignment
    let horizontalAlignment: HorizontalAlignment
    
    let scrollDidStart: () -> Void
    let scrollDidEnd: () -> Void
    
    public init(viewModel: AnyViewModel<PaginatedItemsState<Item>, PaginatedItemsActions<Item>>,
                itemView: @escaping (Item) -> ItemView,
                @ViewBuilder loadingView: () -> LoadingView = { EmptyView() },
                @ViewBuilder emptyListView: () -> EmptyListView = { EmptyView() },
                edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                enableRefresh: Bool = true,
                axis: Axis.Set = .vertical,
                verticalAlignment: VerticalAlignment = .center,
                horizontalAlignment: HorizontalAlignment = .center,
                scrollDidStart: @escaping () -> Void = { },
                scrollDidEnd: @escaping () -> Void = { }) {
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
        self.axis = axis
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
        self.scrollDidStart = scrollDidStart
        self.scrollDidEnd = scrollDidEnd
    }
    
    public var body: some View {
        content
    }
    
    @ViewBuilder
    func listView() -> some View {
        ScrollView(axis) {
            ZStack {
                ScrollViewActionsReader()
                    .scrollDidStart(scrollDidStart)
                    .scrollDidEnd(scrollDidEnd)
                if axis == .horizontal {
                    LazyHStack(alignment: verticalAlignment, spacing: 0) {
                        items
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(edgeInsets)
                } else {
                    LazyVStack(alignment: horizontalAlignment, spacing: 0) {
                        items
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(edgeInsets)
                }
            }
        }
        .scrollIndicators(.hidden)
        .if(enableRefresh) { view in
            view.refreshable {
                await viewModel.trigger(.refresh)
            }
        }
    }
}
