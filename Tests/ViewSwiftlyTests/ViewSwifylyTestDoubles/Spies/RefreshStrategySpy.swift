//
//  RefreshStrategySpy.swift
//  
//
//  Created by Mira Yang on 6/6/24.
//

import Foundation
import ViewSwiftly

class RefreshStrategySpy<Item: Decodable & Identifiable, S: Identifiable>: RefreshStrategy {
    typealias ItemType = Item
    
    var callRefresh: () -> Void
    init(callRefresh: @escaping () -> Void) {
        self.callRefresh = callRefresh
    }
    
    func refresh(vm: PaginatedItemsViewModel<Item>) {
        callRefresh()
    }
}
