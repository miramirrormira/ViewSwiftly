@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest

final class AnyRefreshStrategyTests: XCTestCase {

    func test_refresh() throws {
        var calledRefresh = false
        let strategy = RefreshStrategySpy<Page, Page>(callRefresh: {
            calledRefresh = true
        })
        let sut = AnyRefreshStrategy(strategy)
        XCTAssertFalse(calledRefresh)
        sut.refresh(vm: PaginatedItemsViewModel(requestable: AnyRequestable.init(RequestableDummy())))
        XCTAssertTrue(calledRefresh)
    }
}
