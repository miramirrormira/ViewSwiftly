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
    
    @MainActor @Published public var state: FetchResponseState<ResponseType> = .init()
    let label: String
    
    public let responsePublisher: AnyResponsePublisher<ResponseType>
    var cancellables: Set<AnyCancellable> = []
    
    public init(responsePublisher: AnyResponsePublisher<ResponseType>, label: String = "") {
        self.responsePublisher = responsePublisher
        self.label = label
    }
    
    public init(requestable: AnyRequestable<ResponseType>, label: String = "") {
        self.responsePublisher = AnyResponsePublisher(RequestResponseSubject(requestable: requestable))
        self.label = label
    }
    
    @MainActor
    public func trigger(_ action: FetchResponseActions) async {
        switch action  {
        case .request:
            state.status = .loading
            do {
                try await responsePublisher
                    .publisher()
                    .receive(on: RunLoop.main)
                    .sink { completion in
                    switch completion {
                    case .finished:
                        self.state.status = .success
                    case .failure(let error):
                        self.state.status = .failure(error)
                        Logger.error("\(self.label), failed fetching response: \(error.localizedDescription)")
                    }
                } receiveValue: { value in
                    self.state.response = value
                }
                .store(in: &cancellables)
            } catch {
                self.state.status = .failure(error)
            }
        }
    }
    
    deinit {
        Logger.info("\(ResponseType.Type.self), \(label)")
    }
}

public struct FetchResponseState<ResponseType> {
    public var response: ResponseType?
    public var status: LoadingStatus = .notRequested
}

public enum FetchResponseActions {
    case request
}
