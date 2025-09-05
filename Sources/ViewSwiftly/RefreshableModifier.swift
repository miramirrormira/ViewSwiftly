//
//  RefreshableModifier.swift
//  
//
//  Created by Mira Yang on 5/15/24.
//

import Foundation
import SwiftUI

struct RefreshableModifier: ViewModifier {
    @StateObject private var vm: RefreshableModifierViewModel = .init()
    @Environment(\.refresh) var refresh
    
    func body(content: Content) -> some View {
        VStack {
            if vm.refreshing {
                ProgressView()
            }
            content
        }
        .animation(.default, value: vm.refreshing)
        .background(GeometryReader { geometry in
            Color.clear.preference(key: PreferenceKey.self, value: -geometry.frame(in: .global).origin.y)
        })
        .onPreferenceChange(PreferenceKey.self, perform: { value in
            vm.setRefreshing(with: value)
            if vm.shouldRefresh() {
                vm.setRefreshingTask(Task {
                    await refresh?()
                    vm.reset()
                })
            }
        })
    }
    
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            // No-op
        }
    }
}
