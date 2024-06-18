//
//  FetchedResponseView.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import SwiftUI
import CacheSwiftly
import NetSwiftly

public struct FetchedResponseView<ResponseType, ResponseView: View, ErrorView: View>: View {
    
    @StateObject private var vm: AnyViewModel<FetchResponseState<ResponseType>, FetchResponseActions>
    @ViewBuilder var content: (ResponseType) -> ResponseView
    @ViewBuilder var errorView: (Error) -> ErrorView
    
    public var body: some View {
        Group {
            if let response = vm.state.response {
                content(response)
            } else if let error = vm.state.status.error {
                errorView(error)
            } else {
                ProgressView()
            }
        }
        .task {
            await vm.trigger(.request)
        }
    }
}

extension FetchedResponseView {
    
    public init(with vm: @autoclosure @escaping () -> AnyViewModel<FetchResponseState<ResponseType>, FetchResponseActions>,
                @ViewBuilder content: @escaping (ResponseType) -> ResponseView,
                @ViewBuilder errorView: @escaping (Error) -> ErrorView = { _ in EmptyView() }) {
        self._vm = StateObject(wrappedValue: vm())
        self.content = content
        self.errorView = errorView
    }
    
    public init(from requestable: AnyRequestable<ResponseType>,
                memoryCache: AnyCachable<Task<ResponseType, Error>>? = nil,
                diskCache: AnyCachable<ResponseType>? = nil,
                key: String = "",
                label: String = "",
                @ViewBuilder content: @escaping (ResponseType) -> ResponseView,
                @ViewBuilder errorView: @escaping (Error) -> ErrorView = { _ in EmptyView() }) {
        var finalRequestable = requestable
        if let diskCache = diskCache {
            finalRequestable = AnyRequestable(CachedRequestableDecorator(cache: diskCache, key: key, requestable: requestable))
        }
        if let memoryCache = memoryCache {
            finalRequestable = AnyRequestable(CachedTaskRequestableDecorator(cache: memoryCache, key: key, requestable: finalRequestable))
        }
        self.init(with: AnyViewModel(FetchResponseViewModel<ResponseType>(requestable: finalRequestable, label: label)), 
                  content: content,
                  errorView: errorView)
    }
}
