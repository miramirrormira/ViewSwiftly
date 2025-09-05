@testable import ViewSwiftly
import XCTest
import Combine
import NetSwiftly

final class ResponsePublisherDecoratorTests: XCTestCase {

    func test_publisher_withSuccessReturn1_shouldPublish1() async throws {
        
        let publisherStub = ResponsePublisherStub(returning: 1)
        let sut = ResponsePublisherBaseDecorator(responsePublisher: .init(publisherStub))
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
    
    func test_publisher_withFailure_shouldPublishCorrectError() async throws {
        
        let publisherStub = ResponsePublisherStub<Void>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = ResponsePublisherBaseDecorator(responsePublisher: .init(publisherStub))
        
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
