//
//  OnFetchItemsStrategy.swift
//
//
//  Created by Mira Yang on 6/20/24.
//

import Foundation

public protocol FetchItemsStrategy {
    associatedtype Item
    func onFetchItems(_ items: [Item]) async throws
}
