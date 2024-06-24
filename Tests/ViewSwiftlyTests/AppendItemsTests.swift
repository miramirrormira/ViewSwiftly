@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest

final class AppendItemsTests: XCTestCase {
    
    @MainActor
    func test_merge_with_empty_newItems_array() async throws {
        let sut = AppendItems()
        let vmStub = PaginatedItemsViewModel<Item, Item>.init(requestable: AnyRequestable<[Item]>(RequestableDummy()), mergeItemsStrategy: sut)
        XCTAssertEqual(vmStub.state.items.count, 0)
        try await sut.merge(vm: vmStub, with: [Item]())
        XCTAssertEqual(vmStub.state.items.count, 0)
    }
    
    @MainActor
    func test_merge_with_non_empty_newItems_array() async throws {
        var returningObjects = [Item]()
        let itemsCount = 3
        for i in 0..<itemsCount {
            returningObjects.append(Item(id: "\(i)"))
        }
        let sut = AppendItems()
        let vmStub = PaginatedItemsViewModel<Item, Item>(requestable: AnyRequestable<[Item]>(RequestableDummy()), mergeItemsStrategy: sut)
        XCTAssertEqual(vmStub.state.items.count, 0)
        try await sut.merge(vm: vmStub, with: returningObjects)
        XCTAssertEqual(vmStub.state.items.count, itemsCount)
    }
}


