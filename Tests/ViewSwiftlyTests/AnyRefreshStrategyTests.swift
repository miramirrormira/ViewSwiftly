@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest

final class AnyRefreshStrategyTests: XCTestCase {

    func test_refresh() throws {
        let strategy = RefreshStrategySpy<Page>()
        let sut = AnyRefreshStrategy(strategy)
        XCTAssertFalse(strategy.calledRefresh)
        sut.refresh(vm: PaginatedItemsViewModel(requestable: AnyRequestable.init(RequestableDummy())))
        XCTAssertTrue(strategy.calledRefresh)
    }
}
