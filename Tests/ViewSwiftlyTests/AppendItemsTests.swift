@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest

final class AppendItemsTests: XCTestCase {
    
    @MainActor
    func test_merge_with_empty_newItems_array() async {
        let sut = AppendItems()
        let vmStub = PaginatedItemsViewModel<TestStruct>.init(requestable: AnyRequestable(RequestableDummy()), mergeItemsStrategy: sut)
        XCTAssertEqual(vmStub.state.items.count, 0)
        await sut.merge(vm: vmStub, with: [TestStruct]())
        XCTAssertEqual(vmStub.state.items.count, 0)
    }
    
    @MainActor
    func test_merge_with_non_empty_newItems_array() async {
        var returningObjects = [TestStruct]()
        let itemsCount = 3
        for _ in 0..<itemsCount {
            returningObjects.append(TestStruct())
        }
        let sut = AppendItems()
        let vmStub = PaginatedItemsViewModel<TestStruct>(requestable: AnyRequestable(RequestableDummy()), mergeItemsStrategy: sut)
        XCTAssertEqual(vmStub.state.items.count, 0)
        await sut.merge(vm: vmStub, with: returningObjects)
        XCTAssertEqual(vmStub.state.items.count, itemsCount)
    }
}


