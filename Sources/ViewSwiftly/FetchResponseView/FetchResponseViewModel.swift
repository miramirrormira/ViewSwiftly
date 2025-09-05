//
//  FetchResponseViewModel.swift
//
//
//  Created by Mira Yang on 6/14/24.
//

import Foundation
import Combine
import NetSwiftly
import CacheSwiftly

public class FetchResponseViewModel<Response>: ViewModel {
    
    @MainActor @Published public var state: FetchResponseState<Response> = .init()
    let label: String
    
    public let responsePublisher: AnyResponsePublisher<Response>
    var cancellables: Set<AnyCancellable> = []
    var semaphore: AsyncSemaphore?
    
    public init(responsePublisher: AnyResponsePublisher<Response>, label: String = "", semaphore: AsyncSemaphore? = nil) {
        self.responsePublisher = responsePublisher
        self.label = label
        self.semaphore = semaphore
    }
    
    public init(requestable: AnyRequestable<Response>, label: String = "", semaphore: AsyncSemaphore? = nil) {
        self.responsePublisher = AnyResponsePublisher(RequestResponseSubject(requestable: requestable))
        self.label = label
        self.semaphore = semaphore
    }
    
    @MainActor
    public func trigger(_ action: FetchResponseActions) async {
        switch action  {
        case .request:
            if state.status == .loading {
                return
            }
            state.status = .loading
            do {
                await self.semaphore?.wait()
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
                    } receiveValue: { [weak self] value in
                        self?.semaphore?.signal()
                        self?.state.response = value
                        self?.state.status = .success
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
    public init(response: Response? = nil, status: LoadingStatus = .notRequested) {
        self.response = response
        self.status = status
    }
}

public enum FetchResponseActions {
    case request
}
