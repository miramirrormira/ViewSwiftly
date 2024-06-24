//
//  ViewModelFake.swift
//  
//
//  Created by Mira Yang on 5/8/24.
//

@testable import ViewSwiftly
@testable import NetSwiftly
import Foundation

class ViewModelFake: ViewModel {
    var state: TestStruct
    
    init(state: TestStruct) {
        self.state = state
    }
    
    func trigger(_ action: ViewModelFakeAction) {
        switch action {
        case .increaseValue:
            state.value! += 1
        }
    }
    
    enum ViewModelFakeAction {
        case increaseValue
    }
}
