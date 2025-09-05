@testable import ViewSwiftly
import XCTest

final class AnyFetchItemsStrategyTests: XCTestCase {

    func test_onFetchItems() async throws {
        var calledOnFetchedItems = false
        let spy = FetchedItemsStrategySpy<Void> { _ in
            calledOnFetchedItems = true
        }
        
        let sut = AnyFetchedItemsStrategy(spy)
        
        try await sut.onFetchedItems([])
        
        XCTAssertTrue(calledOnFetchedItems)
    }
}
