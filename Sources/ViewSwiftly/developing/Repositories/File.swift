//
//  File.swift
//  
//
//  Created by Mira Yang on 5/16/24.
//

import Foundation
import NetSwiftly
import Combine

class CachedWebRepository<PersistedContent, WebContent> {
    
    let requestable: AnyRequestable<WebContent>
    let dbRepository: AnyPersistedRepository<PersistedContent>
    let transform: (WebContent) -> PersistedContent
    let cachedValue: CurrentValueSubject<PersistedContent?, Never> = .init(nil)
    let downloadedValue: CurrentValueSubject<PersistedContent?, Never> = .init(nil)
    let passValue: PassthroughSubject<PersistedContent, Never> = .init()
    var cancellables: Set<AnyCancellable> = .init()
    
    init(requestable: AnyRequestable<WebContent>,
         dbRepository: AnyPersistedRepository<PersistedContent>,
         transform: @escaping (WebContent) -> PersistedContent) {
        self.requestable = requestable
        self.dbRepository = dbRepository
        self.transform = transform
        
        cachedValue.sink { [weak self] value in
            guard let strongSelf = self else { return }
            if strongSelf.downloadedValue.value == nil && value != nil {
                strongSelf.passValue.send(value!)
            }
        }
        .store(in: &cancellables)
        
        downloadedValue.sink { [weak self] value in
            guard let strongSelf = self else { return }
            if let value = value {
                strongSelf.cachedValue.value = nil
                strongSelf.passValue.send(value)
            }
        }
        .store(in: &cancellables)
    }
    
    func getContent() async throws {
        await withThrowingTaskGroup(of: Void.self) { group in
            group.addTask { [weak self] in
                let downloaded = try await self?.requestable.request()
                self?.downloadedValue.send(self!.transform(downloaded!))
            }
            group.addTask { [weak self] in
                let cached = try await self?.dbRepository.getContent()
                self?.cachedValue.send(cached!)
            }
        }
    }
}
