//
//  OnFetchItemsStrategy.swift
//
//
//  Created by Mira Yang on 6/20/24.
//

import Foundation

public protocol FetchItemsStrategy {
    associatedtype ItemType
    func onFetchItems(_ items: [ItemType]) async throws
}
