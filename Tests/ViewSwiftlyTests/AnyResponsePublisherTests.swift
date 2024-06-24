@testable import ViewSwiftly
import XCTest
import Combine
import NetSwiftly

final class AnyResponsePublisherTests: XCTestCase {

    func test_publisher_withSuccessReturning1_shouldReturn1() async throws {
        
        let stub = ResponsePublisherStub(returning: 1)
        let sut = AnyResponsePublisher(stub)
        
        var cancellables = Set<AnyCancellable>()
        
        var receivedValue = Int.min
        let expectation = expectation(description: "wait_for_published_value")
        
        try await sut.publisher()
            .sink { _ in
            } receiveValue: { value in
                receivedValue = value
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation])
        
        XCTAssertEqual(receivedValue, 1)
    }
    
    func test_publisher_withFailure_shouldPublishError() async throws {
        
        let stub = ResponsePublisherStub<Int>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = AnyResponsePublisher(stub)
        
        var cancellables = Set<AnyCancellable>()
        let expectation = expectation(description: "wait_for_published_value")
        var receivedError: Error?
        try await sut.publisher()
            .sink { completion in
                switch completion {
                case .finished:
                    XCTFail("should not finish")
                case .failure(let error):
                    receivedError = error
                    expectation.fulfill()
                }
            } receiveValue: { _ in
                XCTFail("should not receive value")
            }
            .store(in: &cancellables)
        
        await fulfillment(of: [expectation])
        
        XCTAssertEqual(receivedError as? NetworkingClientSideError, NetworkingClientSideError.cannotGenerateURL)
    }
}
