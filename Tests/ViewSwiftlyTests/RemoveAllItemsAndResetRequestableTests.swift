@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest

final class RemoveAllItemsAndResetRequestableTests: XCTestCase {

    @MainActor
    func test_refresh() async throws {
        let networkConfiguration = NetworkConfiguration.fixture()
        let endpoint = Endpoint.fixture()
        let paginationQueryStrategy = PageBasedQueryStrategy.fixture()
        let sut = RemoveAllItemsAndResetRequestable(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy)
        
        let vm = PaginatedItemsViewModel<Item>(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy)
        vm.state.items = [Item.init(id: "1")]
        let originalRequestable = vm.requestable
        XCTAssertNotEqual(vm.state.items.count, 0)
        XCTAssertIdentical(vm.requestable, originalRequestable)
        sut.refresh(vm: vm)
        XCTAssertEqual(vm.state.items.count, 0)
        XCTAssertNotIdentical(vm.requestable, originalRequestable)
    }
}
