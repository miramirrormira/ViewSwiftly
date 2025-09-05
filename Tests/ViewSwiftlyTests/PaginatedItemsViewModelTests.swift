@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest

final class PaginatedItemsViewModelTests: XCTestCase {

    func test_attemptLoadNextPage_with_down_scrollDirection_should_return_true_when_the_sut_initialized() throws {
        let requestable = RequestableDummy<[Item]>()
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable))
        XCTAssertNil(sut.firstItemOfLastPage)
        XCTAssertTrue(sut.shouldRequestNextPage(by: Item(id: "")))
    }
    
    func test_attemptLoadNextPage_with_up_scrollDirection_should_return_true_when_the_sut_initialized() throws {
        let requestable = RequestableDummy<[Item]>()
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable), scrollDirection: .up)
        XCTAssertNil(sut.lastItemOfLastPage)
        XCTAssertTrue(sut.shouldRequestNextPage(by: Item(id: "")))
    }
    
    func test_attemptLoadNextPage_with_down_scrollDirection_by_item_unidentical_to_firstItemOfLastPage_should_return_false() async throws {
        let requestable = RequestableStub(returning: [Item(id: "0"), Item(id: "1")])
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable), scrollDirection: .down)
        await sut.trigger(.requestNextPage)
        XCTAssertFalse(sut.shouldRequestNextPage(by: Item(id: "1")))
    }
    
    func test_attemptLoadNextPage_with_up_scrollDirection_by_item_unidentical_to_lastItemOfLastPage_should_return_false() async throws {
        let requestable = RequestableStub(returning: [Item(id: "0"), Item(id: "1")])
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable), scrollDirection: .up)
        await sut.trigger(.requestNextPage)
        XCTAssertFalse(sut.shouldRequestNextPage(by: Item(id: "0")))
    }
    
    func test_attemptLoadNextPage_with_down_scrollDirection_by_item_identical_to_firstItemOfLastPage_should_return_true() async throws {
        let requestable = RequestableStub(returning: [Item(id: "0"), Item(id: "1")])
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable), scrollDirection: .down)
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(sut.shouldRequestNextPage(by: Item(id: "0")))
    }
    
    func test_attemptLoadNextPage_with_up_scrollDirection_by_item_identical_to_lastItemOfLastPage_should_return_true() async throws {
        let requestable = RequestableStub(returning: [Item(id: "0"), Item(id: "1")])
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable), scrollDirection: .up)
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(sut.shouldRequestNextPage(by: Item(id: "1")))
    }
    
    @MainActor
    func test_requestNextPage_with_status_equal_to_loading_should_not_fetch_new_items() async throws {
        let requestable = RequestableStub(returning: [Item(id: "0"), Item(id: "1")])
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable))
        sut.state.status = .loading
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(sut.state.items.isEmpty)
    }
    
    @MainActor
    func test_requestNextPage_with_success_new_items_should_fetch_new_items() async throws {
        let newItems = [Item(id: "0")]
        let requestable = RequestableStub(returning: newItems)
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable))
        XCTAssertFalse(sut.state.items.contains(where: { item in
            item.id == "0"
        }))
        XCTAssertFalse(sut.state.status == .loading)
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(sut.state.items.contains(where: { item in
            item.id == "0"
        }))
    }
    
    @MainActor
    func test_requestNextPage_with_success_new_items_status_should_be_success() async throws {
        let newItems = [Item(id: "0")]
        let requestable = RequestableStub(returning: newItems)
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable))
        XCTAssertNotEqual(sut.state.status, .success)
        await sut.trigger(.requestNextPage)
        XCTAssertEqual(sut.state.status, .success)
    }
    
    @MainActor
    func test_requestNextPage_with_failure_error_should_get_error() async throws {
        
        let requestable = RequestableStub<[Item]>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable))
        XCTAssertEqual(sut.state.status, .notRequested)
        await sut.trigger(.requestNextPage)
        XCTAssertEqual(sut.state.status, LoadingStatus.failure(NetworkingClientSideError.cannotGenerateURL))
    }
    
    @MainActor
    func test_requestNextPage_with_success_new_items_should_trigger_onFetchItems() async throws {
        let newItems = [Item(id: "0")]
        let requestable = RequestableStub(returning: newItems)
        
        var calledOnFetchItems = false
        let fetchedItemsStrategySpy = FetchedItemsStrategySpy<Item> { _ in
            calledOnFetchItems = true
        }
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable), fetchedItemsStrategy: .init(fetchedItemsStrategySpy))
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(calledOnFetchItems)
    }
    
    func test_convenient_init_for_url_requestables_mergeItemsStrategy_should_be_identical() async throws {
        let networkConfiguration = NetworkConfiguration.fixture()
        let endpoint = Endpoint.fixture()
        let paginationQueryStrategy = PageBasedQueryStrategy.fixture()
        let anyMergeItemsStrategy = AnyMergeItemsStrategy<Item>(AppendItems())
        let transform: (Page) -> [Item] = { $0.items }
        let sut = PaginatedItemsViewModel(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, mergeItemsStrategy: anyMergeItemsStrategy, transform: transform)
        
        XCTAssertIdentical(sut.mergeItemsStrategy, anyMergeItemsStrategy)
    
    }
    
    func test_convenient_init_for_url_requestables_onFetchItems_should_be_triggered() async throws {
        let networkConfiguration = NetworkConfiguration.fixture()
        let endpoint = Endpoint.fixture()
        let paginationQueryStrategy = PageBasedQueryStrategy.fixture()
        var calledOnFetchItems = false
        let fetchedItemsStrategySpy = FetchedItemsStrategySpy<Item> { _ in
            calledOnFetchItems = true
        }
        let transform: (Page) -> [Item] = { $0.items }
        let sut = PaginatedItemsViewModel(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, fetchedItemsStrategy: .init(fetchedItemsStrategySpy), transform: transform)
        XCTAssertFalse(calledOnFetchItems)
        XCTAssertNotNil(sut.fetchedItemsStrategy)
        try await sut.fetchedItemsStrategy?.onFetchedItems([])
        XCTAssertTrue(calledOnFetchItems)
    }
}
