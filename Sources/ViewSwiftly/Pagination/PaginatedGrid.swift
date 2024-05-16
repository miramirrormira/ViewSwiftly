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
    
    public init(viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>>,
         itemView: @escaping (T) -> ItemView,
         @ViewBuilder loadingView: () -> LoadingView,
         @ViewBuilder emptyListView: () -> EmptyListView,
         layout: [GridItem],
         edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
         enableRefresh: Bool = true,
         axis: Axis.Set = .vertical) {
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
        self.axis = axis
        self.layout = layout
    }
    
    public var body: some View {
        content
    }
    
    @ViewBuilder
    func listView() -> some View {
        if axis == .horizontal {
            ScrollView(.horizontal) {
                LazyHGrid(rows: layout, spacing: 0) {
                    items
                }
                .padding(edgeInsets)
                .if(enableRefresh) { view in
                    view.refreshable {
                        await viewModel.trigger(.refresh)
                    }
                }
            }
        } else if axis == .vertical {
            ScrollView(.vertical) {
                LazyVGrid(columns: layout, spacing: 0) {
                    items
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
