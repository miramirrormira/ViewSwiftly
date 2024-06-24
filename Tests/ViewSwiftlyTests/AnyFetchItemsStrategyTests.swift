@testable import ViewSwiftly
import XCTest

final class AnyFetchItemsStrategyTests: XCTestCase {

    func test_onFetchItems() async throws {
        var calledOnFetchItems = false
        let spy = FetchItemsStrategySpy<Void> { _ in
            calledOnFetchItems = true
        }
        
        let sut = AnyFetchItemsStrategy(spy)
        
        try await sut.onFetchItems([])
        
        XCTAssertTrue(calledOnFetchItems)
    }
}
