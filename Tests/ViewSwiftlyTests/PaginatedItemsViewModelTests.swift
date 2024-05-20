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
    func test_requestNextPage_with_failure_error_should_get_error() async throws {
        
        let requestable = RequestableStub<Page>(error: NetworkingClientSideError.cannotGenerateURL)
        let sut = PaginatedItemsViewModel<Item, Page>(requestable: AnyRequestable(requestable)) { $0.items }
        XCTAssertEqual(sut.state.status, .notRequested)
        await sut.trigger(.requestNextPage)
        XCTAssertEqual(sut.state.status, PaginatedItemsState.Status.error(NetworkingClientSideError.cannotGenerateURL))
    }
}
