//
//  AssetViewModel.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine
import NetSwiftly

public class FetchResponseViewModel<ResponseType>: ViewModel {
    
    @Published public var state: FetchResponseState<ResponseType> = .init()
    
    public let responsePublisher: AnyResponsePublisher<ResponseType>
    var cancellables: Set<AnyCancellable> = []
    
    public init(responsePublisher: AnyResponsePublisher<ResponseType>) {
        self.responsePublisher = responsePublisher
    }
    
    public init(requestable: AnyRequestable<ResponseType>) {
        self.responsePublisher = AnyResponsePublisher(RequestResponseSubject(requestable: requestable))
    }
    
    public func trigger(_ action: FetchResponseActions) async {
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
                    self.state.response = value
                }
                .store(in: &cancellables)
            } catch {
                self.state.status = .error(error)
            }
        }
    }
}

public struct FetchResponseState<ResponseType> {
    public var response: ResponseType?
    public var status: LoadingStatus = .notRequested
}

public enum FetchResponseActions {
    case request
}
