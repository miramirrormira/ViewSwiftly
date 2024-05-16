//
//  MergeItemsStrategy.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
public protocol MergeItemsStrategy {
    func merge<T>(vm: PaginatedItemsViewModel<T>, with newItems: [T]) async
}
