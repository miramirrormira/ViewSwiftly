@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest
import Combine

final class FallbackPublisherDecoratorTests: XCTestCase {
    
    func test_publisher_persistedRequestPublish0thenNetworkingRequestPublish2_shouldReceiveBothPublishedValues() async throws {
        let persistRequest = AnyRequestable(RequestableStub<Int>(delayInSeconds: 0.0, returning: 0))
        let networkingRequest = AnyRequestable(RequestableStub<Int>(delayInSeconds: 1.0, returning: 2))
        
        let sut = FallbackPublisherDecorator(fallbackRequestable: persistRequest, responseRequestable: networkingRequest)
        
        let expection = expectation(description: "expection")
        var counter = 0
        var finalValue: Int? = nil
        var cancellables = Set<AnyCancellable>()
        try await sut.publisher()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    XCTFail()
                }
                expection.fulfill()
            } receiveValue: { value in
                counter += 1
                finalValue = value
            }
            .store(in: &cancellables)
        await fulfillment(of: [expection])
        XCTAssertEqual(counter, 2)
        XCTAssertEqual(finalValue, 2)
    }
    
    
    func test_publisher_networkingRequestPublish2ThenPersistedRequestPublish0_shouldReceiveNetworkingRequestPublishedValueOnly() async throws {
        let persistRequest = AnyRequestable(RequestableStub<Int>(delayInSeconds: 1.0, returning: 0))
        let networkingRequest = AnyRequestable(RequestableStub<Int>(delayInSeconds: 0.0, returning: 2))
        
        let sut = FallbackPublisherDecorator(fallbackRequestable: persistRequest, responseRequestable: networkingRequest)
        
        let expection = expectation(description: "expection")
        var counter = 0
        var finalValue: Int? = nil
        var cancellables = Set<AnyCancellable>()
        try await sut.publisher()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(_):
                    XCTFail()
                }
                expection.fulfill()
            } receiveValue: { value in
                counter += 1
                finalValue = value
            }
            .store(in: &cancellables)
        await fulfillment(of: [expection])
        XCTAssertEqual(counter, 1)
        XCTAssertEqual(finalValue, 2)
    }
}
