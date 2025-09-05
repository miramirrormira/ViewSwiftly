//
//  PaginatedGrid.swift
//  
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
import SwiftUI

public struct PaginatedGrid<Item: Identifiable & Decodable, ItemView: View, LoadingView: View, EmptyListView: View, ReachedLastItemView: View>: PaginatedItemsView {
    public typealias ItemType = Item
    
    @ObservedObject var viewModel: PaginatedItemsViewModel<Item>
    @ViewBuilder var itemView: (Item) -> ItemView
    
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    var reachedLastItemView: ReachedLastItemView
    var id: String
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    let axis: Axis.Set
    let layout: [GridItem]
    
    let scrollDidStart: (CGRect) -> Void
    let scrollDidEnd: (CGRect) -> Void
    
    var startLoadingOnAppear: Bool
    
    public init(id: String,
                viewModel: PaginatedItemsViewModel<Item>,
                itemView: @escaping (Item) -> ItemView,
                @ViewBuilder loadingView: () -> LoadingView = { ProgressView() },
                @ViewBuilder emptyListView: () -> EmptyListView = { EmptyView() },
                @ViewBuilder reachedLastItemView: () -> ReachedLastItemView = { EmptyView() },
                layout: [GridItem],
                edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                enableRefresh: Bool = true,
                axis: Axis.Set = .vertical,
                scrollDidStart: @escaping (CGRect) -> Void = { _ in },
                scrollDidEnd: @escaping (CGRect) -> Void = { _ in },
                startLoadingOnAppear: Bool = true) {
        self.id = id
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
        self.startLoadingOnAppear = startLoadingOnAppear
        self.reachedLastItemView = reachedLastItemView()
    }
    
    public var body: some View {
        content
    }
    
    @ViewBuilder
    func listView() -> some View {
        ScrollView(axis) {
            ZStack {
                ScrollViewActionsReader(coordinatorSpaceName: self.id)
                    .scrollDidStart(scrollDidStart)
                    .scrollDidEnd (scrollDidEnd)
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
