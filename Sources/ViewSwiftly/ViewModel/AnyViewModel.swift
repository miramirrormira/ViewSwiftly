//
//  AnyViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import Combine

@dynamicMemberLookup
public final class AnyViewModel<State, Action>: ViewModel {
    
    public let wrappedState: () -> State
    public let wrappedTrigger: (Action) async -> Void
    public let wrappedObjectWillChange: () -> ObjectWillChangePublisher
    
    public var objectWillChange: ObjectWillChangePublisher {
        wrappedObjectWillChange()
    }
    
    public var state: State {
        wrappedState()
    }
    
    public func trigger(_ action: Action) async {
        await wrappedTrigger(action)
    }
    
    public init<V: ViewModel>(_ viewModel: V) where V.State == State, V.Action == Action, V.ObjectWillChangePublisher == ObjectWillChangePublisher {
        self.wrappedState = { viewModel.state }
        self.wrappedTrigger = viewModel.trigger(_:)
        self.wrappedObjectWillChange = { viewModel.objectWillChange }
    }
    
    subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        self.state[keyPath: keyPath]
    }
}
