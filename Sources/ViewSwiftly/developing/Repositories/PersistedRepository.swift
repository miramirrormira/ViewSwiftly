//
//  File.swift
//  
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation

public protocol PersistedRepository: Repository {
    func save(_ content: Content) async throws
}
