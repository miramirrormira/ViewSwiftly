//
//  File.swift
//  
//
//  Created by Mira Yang on 5/19/24.
//

import Foundation

struct Page: Decodable {
    var items: [Item]
}

struct Item: Identifiable, Decodable {
    var id: String
}
