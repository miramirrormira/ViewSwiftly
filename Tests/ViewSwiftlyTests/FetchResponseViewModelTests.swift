@testable import ViewSwiftly
import XCTest
import NetSwiftly
import Combine

final class FetchResponseViewModelTests: XCTestCase {

    @MainActor
    func test_request_withSuccessReturn1_initWithPublisher_shouldPublish1() async throws {
        let responsePublisher = ResponsePublisherStub(returning: 1)
        let sut = FetchResponseViewModel(responsePublisher: .init(responsePublisher), label: "test")
        await sut.trigger(.request)
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertEqual(sut.state.response, 1)
        XCTAssertEqual(sut.state.status, .success)
        XCTAssertEqual(sut.label, "test")
    }
    
    @MainActor
    func test_request_withFailure_initWithPublisher_shouldPublishError() async throws {
        let responsePublisher = ResponsePublisherStub<Void>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = FetchResponseViewModel(responsePublisher: .init(responsePublisher), label: "test")
        await sut.trigger(.request)
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertNil(sut.state.response)
        XCTAssertEqual(sut.label, "test")
        XCTAssertEqual(sut.state.status.error as? NetworkingClientSideError, NetworkingClientSideError.cannotGenerateURL)
    }
    
    @MainActor
    func test_request_withSuccessReturn1_initWithRequest_shouldPublish1() async throws {
        let requestable = RequestableStub(returning: 1)
        let sut = FetchResponseViewModel(requestable: .init(requestable), label: "test")
        await sut.trigger(.request)
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertEqual(sut.state.response, 1)
        XCTAssertEqual(sut.state.status, .success)
        XCTAssertEqual(sut.label, "test")
    }
    
    @MainActor
    func test_request_withFailure_initWithRequest_shouldPublishError() async throws {
        let requestable = RequestableStub<Void>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = FetchResponseViewModel(requestable: .init(requestable), label: "test")
        await sut.trigger(.request)
        try await Task.sleep(nanoseconds: 500_000_000)
        XCTAssertNil(sut.state.response)
        XCTAssertEqual(sut.label, "test")
        XCTAssertEqual(sut.state.status.error as? NetworkingClientSideError, NetworkingClientSideError.cannotGenerateURL)
    }
}
