//
//  FetchResponseViewModel.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine
import NetSwiftly

public class FetchResponseViewModel<Response>: ViewModel {
    
    @MainActor @Published public var state: FetchResponseState<Response> = .init()
    let label: String
    
    public let responsePublisher: AnyResponsePublisher<Response>
    var cancellables: Set<AnyCancellable> = []
    
    public init(responsePublisher: AnyResponsePublisher<Response>, label: String = "") {
        self.responsePublisher = responsePublisher
        self.label = label
    }
    
    public init(requestable: AnyRequestable<Response>, label: String = "") {
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
                    .sink { [weak self, label] completion in
                        guard let strongSelf = self else {
                            Logger.error("\(label), self is nil")
                            return
                        }
                        switch completion {
                        case .finished:
                            strongSelf.state.status = .success
                        case .failure(let error):
                            strongSelf.state.status = .failure(error)
                            Logger.error("\(strongSelf.label), failed fetching response: \(error.localizedDescription)")
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
        Logger.info("\(Response.Type.self), \(label)")
    }
}

public struct FetchResponseState<Response> {
    public var response: Response?
    public var status: LoadingStatus = .notRequested
}

public enum FetchResponseActions {
    case request
}
