//
//  PaginatedLazyHStack.swift
//
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
import SwiftUI

#warning("Get rid of this macro when we drop support for iOS 17")
@available(iOS 18.0, *)
public struct PaginatedLazyHStack<Item: Identifiable & Decodable & Equatable, ItemView: View, LoadingView: View, EmptyListView: View, ReachedLastItemView: View>: PaginatedItemsView {
    
    @ObservedObject var viewModel: PaginatedItemsViewModel<Item>
    @ViewBuilder var itemView: (Item) -> ItemView
    
    var loadingView: LoadingView
    var emptyListView: EmptyListView
    var id: String
    var reachedLastItemView: ReachedLastItemView
    
    let spacing: CGFloat
    let edgeInsets: EdgeInsets
    let enableRefresh: Bool
    let verticalAlignment: VerticalAlignment
    let paging: Bool
    
    let scrollDidStart: (CGRect) -> Void
    let scrollDidEnd: (CGRect) -> Void
    let onOffsetChange: ((CGRect) -> Void)
    
    var onScrollPhaseChangeAction: ((ScrollPhase, ScrollPhase) -> Void)?
    var startLoadingOnAppear: Bool
    var onAppearActionForScrollView: (() -> Void)?
    
    public init(id: String,
                viewModel: PaginatedItemsViewModel<Item>,
                @ViewBuilder itemView: @escaping (Item) -> ItemView,
                @ViewBuilder loadingView: () -> LoadingView = { ProgressView() },
                @ViewBuilder emptyListView: () -> EmptyListView = { EmptyView() },
                @ViewBuilder reachedLastItemView: () -> ReachedLastItemView = { EmptyView() },
                spacing: CGFloat = 0,
                edgeInsets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
                enableRefresh: Bool = true,
                paging: Bool = false,
                verticalAlignment: VerticalAlignment = .center,
                scrollDidStart: @escaping (CGRect) -> Void = { _ in },
                scrollDidEnd: @escaping (CGRect) -> Void = { _ in },
                onOffsetChange: @escaping (CGRect) -> Void = { _ in },
                startLoadingOnAppear: Bool = true,
                onAppearActionForScrollView: (() -> Void)? = nil,
                onScrollPhaseChangeAction: ((ScrollPhase, ScrollPhase) -> Void)? = nil,
    ){
        self.id = id
        self.viewModel = viewModel
        self.itemView = itemView
        self.loadingView = loadingView()
        self.emptyListView = emptyListView()
        self.reachedLastItemView = reachedLastItemView()
        self.spacing = spacing
        self.edgeInsets = edgeInsets
        self.enableRefresh = enableRefresh
        self.verticalAlignment = verticalAlignment
        self.paging = paging
        self.scrollDidStart = scrollDidStart
        self.scrollDidEnd = scrollDidEnd
        self.onOffsetChange = onOffsetChange
        self.startLoadingOnAppear = startLoadingOnAppear
        self.onAppearActionForScrollView = onAppearActionForScrollView
        self.onScrollPhaseChangeAction = onScrollPhaseChangeAction
    }
    
    public var body: some View {
        content
    }
    
    @ViewBuilder
    func listView() -> some View {
        ScrollView(.horizontal) {
            ZStack {
                ScrollViewActionsReader(coordinatorSpaceName: self.id)
                    .scrollDidStart(scrollDidStart)
                    .scrollDidEnd(scrollDidEnd)
                    .onOffsetChange { offset in
                        onOffsetChange(offset)
                        viewModel.state.scrollOffset = offset
                    }
                LazyHStack(alignment: verticalAlignment, spacing: spacing) {
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

struct DebounceOnChange<Value: Equatable>: ViewModifier {
    let value: Value?
    let interval: UInt64
    let action: (Value?, Value?) -> Void
    
    @State private var task: Task<Void, Never>? = nil
    @State private var oldValue: Value? = nil
    
    func body(content: Content) -> some View {
        content.onChange(of: value) {
            let previous = oldValue
            
            oldValue = value
            // cancel old
            task?.cancel()
            // schedule new
            task = Task {
                try? await Task.sleep(nanoseconds: interval * 1_000_000)
                guard !Task.isCancelled else { return }
                action(previous,value)
            }
        }
    }
}

extension View {
    /// Debounce an `onChange` by the given interval in nanoseconds.
    func onChangeDebounced<Value: Equatable>(
        of value: Value?,
        debounceFor interval: UInt64,
        perform action: @escaping (Value?,Value?) -> Void
    ) -> some View {
        modifier(DebounceOnChange(value: value, interval: interval, action: action))
    }
}
