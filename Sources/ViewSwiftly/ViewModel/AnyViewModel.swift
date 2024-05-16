//
//  AnyViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import Combine

final class AnyViewModel<State, Action>: ViewModel {
    
    private let wrappedState: () -> State
    private let wrappedTrigger: (Action) async -> Void
    private let wrappedObjectWillChange: () -> ObjectWillChangePublisher
    
    var objectWillChange: ObjectWillChangePublisher {
        wrappedObjectWillChange()
    }
    
    var state: State {
        wrappedState()
    }
    
    func trigger(_ action: Action) async {
        await wrappedTrigger(action)
    }
    
    init<V: ViewModel>(_ viewModel: V) where V.State == State, V.Action == Action, V.ObjectWillChangePublisher == ObjectWillChangePublisher {
        self.wrappedState = { viewModel.state }
        self.wrappedTrigger = viewModel.trigger(_:)
        self.wrappedObjectWillChange = { viewModel.objectWillChange }
    }
}
