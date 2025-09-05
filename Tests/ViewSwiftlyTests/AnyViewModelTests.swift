@testable import ViewSwiftly
@testable import NetSwiftly
import XCTest
import Combine

final class AnyViewModelTests: XCTestCase {

    func test_state() {
        
        let vm = ViewModelFake(state: TestStruct(value: 0))
        let anyVM = AnyViewModel(vm)
        var anyVMState = anyVM.state
        XCTAssertEqual(anyVMState, vm.state)
        vm.state.value = 10
        anyVMState = anyVM.state
        XCTAssertEqual(anyVMState, vm.state)
    }
    
    func test_trigger() async {
        let vm = ViewModelFake(state: TestStruct(value: 0))
        let anyVM = AnyViewModel(vm)
        var anyVMState = anyVM.state.value
        XCTAssertEqual(anyVMState, 0)
        await anyVM.trigger(.increaseValue)
        anyVMState = anyVM.state.value
        XCTAssertEqual(anyVMState, 1)
    }
    
    func test_objectWillChange() {
        let vm = ViewModelFake(state: TestStruct())
        let anyVM = AnyViewModel(vm)
        XCTAssertIdentical(vm.objectWillChange, anyVM.objectWillChange)
    }
    
}
