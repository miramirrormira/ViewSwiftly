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

public struct FetchResponseView<Response, ResponseView: View, ErrorView: View>: View {
    
    @ObservedObject private var vm: AnyViewModel<FetchResponseState<Response>, FetchResponseActions>
    @ViewBuilder var content: (Response) -> ResponseView
    @ViewBuilder var errorView: (Error) -> ErrorView
    let label: String
    
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
        .id(label)
        .onAppear {
            Task {
                await vm.trigger(.request)
            }
        }
    }
}

extension FetchResponseView {
    
    public init(with vm: AnyViewModel<FetchResponseState<Response>, FetchResponseActions>,
                @ViewBuilder content: @escaping (Response) -> ResponseView,
                @ViewBuilder errorView: @escaping (Error) -> ErrorView = { _ in EmptyView() },
                label: String = "") {
        self.vm = vm
        self.content = content
        self.errorView = errorView
        self.label = label
    }
}
