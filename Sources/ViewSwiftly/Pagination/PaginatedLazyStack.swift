//
//  PaginatedLazyStack.swift
//
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
import SwiftUI

public struct PaginatedLazyStack<T: Identifiable, ItemView: View, LoadingView: View, EmptyListView: View>: PaginatedItemsView {

    @ObservedObject var viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>>
    
    @ViewBuilder var itemView: (T) -> ItemView
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    let axis: Axis.Set
    let verticalAlignment: VerticalAlignment
    let horizontalAlignment: HorizontalAlignment
    
    init(viewModel: AnyViewModel<PaginatedItemsState<T>, PaginatedItemsActions<T>>,
         itemView: @escaping (T) -> ItemView,
         @ViewBuilder loadingView: () -> LoadingView,
         @ViewBuilder emptyListView: () -> EmptyListView,
         edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
         enableRefresh: Bool = true,
         axis: Axis.Set = .vertical,
         verticalAlignment: VerticalAlignment = .center,
         horizontalAlignment: HorizontalAlignment = .center) {
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
        self.axis = axis
        self.verticalAlignment = verticalAlignment
        self.horizontalAlignment = horizontalAlignment
    }
    
    public var body: some View {
        content
    }
    
    @ViewBuilder
    func listView() -> some View {
        if axis == .vertical {
            ScrollView(.vertical) {
                LazyVStack(alignment: horizontalAlignment, spacing: 0) {
                    items
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(edgeInsets)
            }
            .scrollIndicators(.hidden)
            .if(enableRefresh) { view in
                view.refreshable {
                    await viewModel.trigger(.refresh)
                }
            }
            
        } else if axis == .horizontal {
            ScrollView(.horizontal) {
                LazyHStack(alignment: verticalAlignment, spacing: 0) {
                    items
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(edgeInsets)
            }
            .scrollIndicators(.hidden)
            .if(enableRefresh) { view in
                view.refreshable {
                    await viewModel.trigger(.refresh)
                }
            }
        }
    }
}
