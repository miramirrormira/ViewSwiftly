//
//  PaginatedGrid.swift
//  
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
import SwiftUI

public struct PaginatedGrid<T: Identifiable, ItemView: View, LoadingView: View, EmptyListView: View>: PaginatedItemsView {
    
    @ObservedObject var viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>>
    
    @ViewBuilder var itemView: (T) -> ItemView
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    let axis: Axis.Set
    let layout: [GridItem]
    
    let scrollDidStart: () -> Void
    let scrollDidEnd: () -> Void
    
    public init(viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>>,
                itemView: @escaping (T) -> ItemView,
                @ViewBuilder loadingView: () -> LoadingView = { EmptyView() },
                @ViewBuilder emptyListView: () -> EmptyListView = { EmptyView() },
                layout: [GridItem],
                edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                enableRefresh: Bool = true,
                axis: Axis.Set = .vertical,
                scrollDidStart: @escaping () -> Void = { },
                scrollDidEnd: @escaping () -> Void = { }) {
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
        self.axis = axis
        self.layout = layout
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
                Group {
                    if axis == .horizontal {
                        LazyHGrid(rows: layout, spacing: 0) {
                            items
                        }
                    } else {
                        LazyVGrid(columns: layout, spacing: 0) {
                            items
                        }
                    }
                }
                .padding(edgeInsets)
                .if(enableRefresh) { view in
                    view.refreshable {
                        await viewModel.trigger(.refresh)
                    }
                }
            }
        }
    }
}
