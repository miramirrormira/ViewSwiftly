//
//  RefreshableModifierViewModel.swift
//
//
//  Created by Mira Yang on 5/25/24.
//

import Foundation
import SwiftUI

@MainActor
class RefreshableModifierViewModel: ObservableObject {
    @Published var refreshing: Bool = false
    var refreshingTask: Task<Void, Never>?
    
    func setRefreshing(with offset: CGFloat) {
        self.refreshing = offset < -80
    }
    
    func setRefreshing(_ refreshing: Bool) {
        self.refreshing = refreshing
    }
    
    func setRefreshingTask(_ task: Task<Void, Never>?) {
        self.refreshingTask = task
    }
    
    func shouldRefresh() -> Bool {
        refreshingTask == nil && refreshing == false
    }
    
    func reset() {
        refreshingTask = nil
        refreshing = false
    }
}
