@testable import ViewSwiftly
@testable import NetSwiftly
import Combine
import XCTest

final class RequestResponseSubjectTests: XCTestCase {

    func test_publisher_withSuccessReturn1_shouldPublish1() async throws {
        let requestableStub = RequestableStub(returning: 1)
        let sut = RequestResponseSubject<Int>(requestable: .init(requestableStub))
        var cancellables = Set<AnyCancellable>()
        
        var receivedValue = Int.min
        let expectation = expectation(description: "wait_for_published_value")
        
        sut.publisher()
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
        let requestableStub = RequestableStub<Int>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = RequestResponseSubject<Int>(requestable: .init(requestableStub))
        var cancellables = Set<AnyCancellable>()
        
        let expectation = expectation(description: "wait_for_published_value")
        var receivedError: Error?
        sut.publisher()
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
