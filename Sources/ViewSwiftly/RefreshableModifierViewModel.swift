//
//  RefreshableModifierViewModel.swift
//
//
//  Created by Mira Yang on 5/25/24.
//

import Foundation
import SwiftUI

class RefreshableModifierViewModel: ObservableObject {
    @Published var isRefreshing: Bool = false
    @Environment(\.refresh) var refresh
    
    func onOffsetChange(_ offset: CGFloat) {
        if offset < -80 && isRefreshing == false {
            isRefreshing = true
            Task {
                await refresh?()
                isRefreshing = false
            }
        }
    }
}
