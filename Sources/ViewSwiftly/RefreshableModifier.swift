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
    
    func body(content: Content) -> some View {
        VStack {
            if vm.isRefreshing {
                ProgressView()
            }
            content
        }
        .animation(.default, value: vm.isRefreshing)
        .background(GeometryReader { geometry in
            Color.clear.preference(key: PreferenceKey.self, value: -geometry.frame(in: .global).origin.y)
        })
        .onPreferenceChange(PreferenceKey.self, perform: vm.onOffsetChange(_:))
    }
    
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            // No-op
        }
    }
}
