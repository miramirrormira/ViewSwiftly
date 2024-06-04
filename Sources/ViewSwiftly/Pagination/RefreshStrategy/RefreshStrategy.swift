//
//  File.swift
//  
//
//  Created by Mira Yang on 6/1/24.
//

import Foundation

public protocol RefreshStrategy {
    func refresh<ItemType, PageType>(vm: PaginatedItemsViewModel<ItemType, PageType>)
}
