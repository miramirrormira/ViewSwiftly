//
//  RefreshStrategySpy.swift
//  
//
//  Created by Mira Yang on 6/6/24.
//

import Foundation
import ViewSwiftly

class RefreshStrategySpy<T: Decodable & Identifiable>: RefreshStrategy {
    typealias ItemType = T
    
    var calledRefresh: Bool = false
    
    func refresh(vm: PaginatedItemsViewModel<ItemType>) {
        calledRefresh = true
    }
}
