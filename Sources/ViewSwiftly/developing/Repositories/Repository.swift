//
//  Repository.swift
//
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation

public protocol Repository {
    associatedtype Content
    func getContent() async throws -> Content?
}
