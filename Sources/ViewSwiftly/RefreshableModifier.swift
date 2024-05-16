//
//  File.swift
//  
//
//  Created by Mira Yang on 5/15/24.
//

import Foundation
import SwiftUI

struct RefreshableModifier: ViewModifier {
    
    @Environment(\.refresh) private var refresh
    @State private var isRefreshing = false
    
    func body(content: Content) -> some View {
        VStack {
            if isRefreshing {
                ProgressView()
            }
            content
        }
        .animation(.default, value: isRefreshing)
        .background(GeometryReader {
            Color.clear.preference(key: PreferenceKey.self, value: -$0.frame(in: .global).origin.y)
        })
        .onPreferenceChange(PreferenceKey.self) {
            if $0 < -80 && isRefreshing == false {
                isRefreshing = true
                Task {
                    await refresh?()
                    isRefreshing = false
                }
            }
        }
    }
    
    struct PreferenceKey: SwiftUI.PreferenceKey {
        static var defaultValue: CGFloat { 0 }
        static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
            // No-op
        }
    }
}
