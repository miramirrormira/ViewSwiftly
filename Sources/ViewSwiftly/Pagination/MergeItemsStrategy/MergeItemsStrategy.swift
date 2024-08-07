//
//  MergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
public protocol MergeItemsStrategy {
    associatedtype ItemType: Decodable & Identifiable
    associatedtype ItemStateType: Identifiable
    func merge(vm: PaginatedItemsViewModel<ItemType, ItemStateType>, with newItems: [ItemType]) async throws
}
