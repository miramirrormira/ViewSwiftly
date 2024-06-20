//
//  OnFetchItemStrategy.swift
//  
//
//  Created by Mira Yang on 6/20/24.
//

import Foundation

public protocol OnFetchItemStrategy {
    func onFetchItems<ItemType>(_ items: [ItemType]) async throws
}
