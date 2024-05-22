@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest

final class PaginatedItemsViewModelTests: XCTestCase {

    func test_attemptLoadNextPage_should_return_true_when_the_sut_initialized() throws {
        let requestable = RequestableDummy<Page>()
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
        XCTAssertNil(sut.firstItemOfLastPage)
        XCTAssertTrue(sut.shouldRequestNextPage(by: Item(id: "")))
    }
    
    func test_attemptLoadNextPage_by_item_unidentical_to_firstItemOfLastPage_should_return_false() async throws {
        let requestable = RequestableStub(returning: Page(items: [Item(id: "0"), Item(id: "1")]))
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
        await sut.trigger(.requestNextPage)
        XCTAssertFalse(sut.shouldRequestNextPage(by: Item(id: "1")))
    }
    
    func test_attemptLoadNextPage_by_item_identical_to_firstItemOfLastPage_should_return_true() async throws {
        let requestable = RequestableStub(returning: Page(items: [Item(id: "0"), Item(id: "1")]))
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(sut.shouldRequestNextPage(by: Item(id: "0")))
    }
    
    @MainActor
    func test_requestNextPage_with_status_equal_to_loading_should_not_fetch_new_items() async throws {
        let requestable = RequestableStub(returning: Page(items: [Item(id: "0"), Item(id: "1")]))
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
        sut.state.status = .loading
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(sut.state.items.isEmpty)
    }
    
    @MainActor
    func test_requestNextPage_with_success_new_items_should_fetch_new_items() async throws {
        let newItems = [Item(id: "0")]
        let requestable = RequestableStub(returning: Page(items: newItems))
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
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
        let requestable = RequestableStub(returning: Page(items: newItems))
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
        XCTAssertNotEqual(sut.state.status, .success)
        await sut.trigger(.requestNextPage)
        XCTAssertEqual(sut.state.status, .success)
    }
    
    @MainActor
    func test_requestNextPage_with_failure_error_should_get_error() async throws {
        
        let requestable = RequestableStub<Page>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
        XCTAssertEqual(sut.state.status, .notRequested)
        await sut.trigger(.requestNextPage)
        XCTAssertEqual(sut.state.status, PaginatedItemsState.Status.error(NetworkingClientSideError.cannotGenerateURL))
    }
    
    @MainActor
    func test_requestNextPage_with_success_new_items_should_trigger_onFetchItems() async throws {
        let newItems = [Item(id: "0")]
        let requestable = RequestableStub(returning: Page(items: newItems))
        
        var calledOnFetchItems = false
        let onFetchItems: ([Item]) async throws -> Void = { _ in
            calledOnFetchItems = true
        }
        let sut = PaginatedItemsViewModel(requestable: AnyRequestable(requestable), transform: { $0.items }, onFetchItems: onFetchItems)
        await sut.trigger(.requestNextPage)
        XCTAssertTrue(calledOnFetchItems)
    }
    
    func test_convenient_init_for_url_requestables_mergeItemsStrategy_should_be_identical() async throws {
        let networkConfiguration = NetworkConfiguration.fixture()
        let endpoint = Endpoint.fixture()
        let paginationQueryStrategy = PageBasedQueryStrategy.fixture()
        let mergeItemsStrategy = AppendItems()
        
        let sut = PaginatedItemsViewModel<Item, Page>(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, transform: { $0.items }, mergeItemsStrategy: mergeItemsStrategy)
        
        XCTAssertIdentical(sut.mergeItemsStrategy as? AppendItems, mergeItemsStrategy)
    }
    
    func test_convenient_init_for_url_requestables_onFetchItems_should_be_triggered() async throws {
        let networkConfiguration = NetworkConfiguration.fixture()
        let endpoint = Endpoint.fixture()
        let paginationQueryStrategy = PageBasedQueryStrategy.fixture()
        var calledOnFetchItems = false
        let onFetchItems: ([Item]) async throws -> Void = { _ in calledOnFetchItems = true }
        
        let sut = PaginatedItemsViewModel<Item, Page>(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, transform: { $0.items }, onFetchItems: onFetchItems)
        XCTAssertFalse(calledOnFetchItems)
        XCTAssertNotNil(sut.onFetchItems)
        try await sut.onFetchItems?([])
        XCTAssertTrue(calledOnFetchItems)
    }
    
    func test_convenient_init_for_url_requestables_transform_should_be_triggered() async throws {
        let networkConfiguration = NetworkConfiguration.fixture()
        let endpoint = Endpoint.fixture()
        let paginationQueryStrategy = PageBasedQueryStrategy.fixture()
        var calledTransform = false
        let transform: (Page) async throws -> [Item] = { page in
            calledTransform = true
            return page.items
        }
        let sut = PaginatedItemsViewModel<Item, Page>(networkConfiguration: networkConfiguration, endpoint: endpoint, paginationQueryStrategy: paginationQueryStrategy, transform: transform)
        XCTAssertFalse(calledTransform)
        let _ = try await sut.transform(Page(items: []))
        XCTAssertTrue(calledTransform)
    }
}
