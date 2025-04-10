//
//  RefreshStrategy.swift
//
//
//  Created by Mira Yang on 6/1/24.
//

import Foundation

public protocol RefreshStrategy {
    associatedtype ItemType: Decodable & Identifiable
    func refresh(vm: PaginatedItemsViewModel<ItemType>)
}
