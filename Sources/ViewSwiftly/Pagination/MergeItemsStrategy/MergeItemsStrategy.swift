//
//  MergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
public protocol MergeItemsStrategy {
    associatedtype ItemType: Decodable & Identifiable
    func merge(vm: PaginatedItemsViewModel<ItemType>, with newItems: [ItemType]) async throws
}
