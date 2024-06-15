//
//  ImageAssetView.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import SwiftUI
import CacheSwiftly
import NetSwiftly

public struct FetchedResponseView<ResponseType, ResponseView: View>: View {
    
    @ObservedObject private var vm: AnyViewModel<FetchResponseState<ResponseType>, FetchResponseActions>
    @ViewBuilder var content: (ResponseType) -> ResponseView
    
    public var body: some View {
        if vm.state.status == .loading {
            ProgressView()
        } else if let response = vm.state.response {
            content(response)
        }
    }
}

extension FetchedResponseView {
    
    public init(with vm: AnyViewModel<FetchResponseState<ResponseType>, FetchResponseActions>,
                @ViewBuilder content: @escaping (ResponseType) -> ResponseView) {
        self.vm = vm
        self.content = content
        Task {
            await vm.trigger(.request)
        }
    }
    
    public init(from requestable: AnyRequestable<ResponseType>,
                memoryCache: AnyCachable<Task<ResponseType, Error>>,
                key: String,
                @ViewBuilder content: @escaping (ResponseType) -> ResponseView) {
        let cachedRequestable = CachedTaskRequestableDecorator(cache: memoryCache, key: key, requestable: requestable)
        let vm = AnyViewModel(FetchResponseViewModel<ResponseType>(requestable: AnyRequestable(cachedRequestable)))
        self.init(with: vm, content: content)
    }
    
    public init(from requestable: AnyRequestable<ResponseType>,
                memoryCache: AnyCachable<Task<ResponseType, Error>>,
                diskCache: AnyCachable<ResponseType>,
                key: String,
                @ViewBuilder content: @escaping (ResponseType) -> ResponseView) {
        let diskCachedRequestable = CachedRequestableDecorator(cache: diskCache, key: key, requestable: requestable)
        let layerCachedRequestable = CachedTaskRequestableDecorator(cache: memoryCache, key: key, requestable: AnyRequestable(diskCachedRequestable))
        let vm = AnyViewModel(FetchResponseViewModel<ResponseType>(requestable: AnyRequestable(layerCachedRequestable)))
        self.init(with: vm, content: content)
    }
}
