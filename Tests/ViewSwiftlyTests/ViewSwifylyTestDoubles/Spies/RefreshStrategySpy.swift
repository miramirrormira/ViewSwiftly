//
//  RefreshStrategySpy.swift
//  
//
//  Created by Mira Yang on 6/6/24.
//

import Foundation
import ViewSwiftly

class RefreshStrategySpy<T: Decodable & Identifiable, S: Identifiable>: RefreshStrategy {
    typealias ItemStateType = S
    typealias ItemType = T
    
    var callRefresh: () -> Void
    init(callRefresh: @escaping () -> Void) {
        self.callRefresh = callRefresh
    }
    
    func refresh(vm: PaginatedItemsViewModel<ItemType, ItemStateType>) {
        callRefresh()
    }
}
