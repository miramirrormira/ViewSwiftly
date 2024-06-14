//
//  AssetViewModel.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine

public class AssetViewModel<AssetType>: ViewModel {
    
    public var state: AssetState<AssetType> = .init()
    
    public let responsePublisher: AnyResponsePublisher<AssetType>
    var cancellables: Set<AnyCancellable> = []
    
    public init(responsePublisher: AnyResponsePublisher<AssetType>) {
        self.responsePublisher = responsePublisher
    }
    
    public func trigger(_ action: AssetActions) async {
        switch action  {
        case .request:
            state.status = .loading
            do {
                try await responsePublisher.publisher().sink { completion in
                    switch completion {
                    case .finished:
                        self.state.status = .success
                    case .failure(let error):
                        self.state.status = .error(error)
                    }
                } receiveValue: { value in
                    self.state.asset = value
                }
                .store(in: &cancellables)
            } catch {
                self.state.status = .error(error)
            }
        }
    }
}


public struct AssetState<AssetType> {
    public var asset: AssetType?
    public var status: LoadingStatus = .notRequested
}

public enum AssetActions {
    case request
}
