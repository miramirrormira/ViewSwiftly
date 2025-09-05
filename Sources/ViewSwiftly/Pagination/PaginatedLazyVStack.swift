//
//  PaginatedLazyVStack.swift
//
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
import SwiftUI

#warning("Get rid of this macro when we drop support for iOS 17")
@available(iOS 18.0, *)
public struct PaginatedLazyVStack<Item: Identifiable & Decodable & Equatable, ItemView: View, LoadingView: View, EmptyListView: View, ReachedLastItemView: View>: PaginatedItemsView {
    
    @ObservedObject var viewModel: PaginatedItemsViewModel<Item>
    @ViewBuilder var itemView: (Item) -> ItemView
    
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    var id: String
    var reachedLastItemView: ReachedLastItemView
    
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    let horizontalAlignment: HorizontalAlignment
    let paging: Bool
    
    let scrollDidStart: (CGRect) -> Void
    let scrollDidEnd: (CGRect) -> Void
    
    var onScrollPhaseChangeAction: ((ScrollPhase, ScrollPhase) -> Void)?
    var startLoadingOnAppear: Bool
    var onAppearActionForScrollView: (() -> Void)?
    var onChangeOfFocusedItem: ((Item?, Item?) -> Void)?
    
    public init(id: String,
                viewModel: PaginatedItemsViewModel<Item>,
                @ViewBuilder itemView: @escaping (Item) -> ItemView,
                @ViewBuilder loadingView: () -> LoadingView = { ProgressView() },
                @ViewBuilder emptyListView: () -> EmptyListView = { EmptyView() },
                @ViewBuilder reachedLastItemView: () -> ReachedLastItemView = { EmptyView() },
                edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                enableRefresh: Bool = true,
                paging: Bool = false,
                horizontalAlignment: HorizontalAlignment = .center,
                scrollDidStart: @escaping (CGRect) -> Void = { _ in },
                scrollDidEnd: @escaping (CGRect) -> Void = { _ in },
                startLoadingOnAppear: Bool = true,
                onAppearActionForScrollView: (() -> Void)? = nil,
                onScrollPhaseChangeAction: ((ScrollPhase, ScrollPhase) -> Void)? = nil,
                onChangeOfFocusedItem: ((Item?, Item?) -> Void)? = nil
    ){
        self.id = id
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
        self.horizontalAlignment = horizontalAlignment
        self.paging = paging
        self.scrollDidStart = scrollDidStart
        self.scrollDidEnd = scrollDidEnd
        self.startLoadingOnAppear = startLoadingOnAppear
        self.reachedLastItemView = reachedLastItemView()
        self.onAppearActionForScrollView = onAppearActionForScrollView
        self.onScrollPhaseChangeAction = onScrollPhaseChangeAction
    }
    
    public var body: some View {
        content
    }
    
    @ViewBuilder
    func listView() -> some View {
        ScrollView(.vertical) {
            ZStack {
                ScrollViewActionsReader(coordinatorSpaceName: self.id)
                    .scrollDidStart(scrollDidStart)
                    .scrollDidEnd(scrollDidEnd)
                LazyVStack(alignment: horizontalAlignment, spacing: 0) {
                    items
                }
                .scrollTargetLayout()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(edgeInsets)
            }
        }
        .onAppear {
            onAppearActionForScrollView?()
        }
        .scrollPosition(id: $viewModel.state.scrollPositionId, anchor: viewModel.state.scrollPositionAnchorUnitPoint)
        .onScrollPhaseChange(onScrollPhaseChangeAction ?? { _,_ in })
        .scrollIndicators(.hidden)
        .scrollTargetBehavior(paging ? .viewAligned(limitBehavior: .alwaysByOne) : .viewAligned)
        .if(enableRefresh) { view in
            view.refreshable {
                await viewModel.trigger(.refresh)
            }
        }
    }
}
