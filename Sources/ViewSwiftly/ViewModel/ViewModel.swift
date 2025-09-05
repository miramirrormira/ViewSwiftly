//
//  ViewModel.swift
//
//
//  Created by Mira Yang on 5/8/24.
//

import Foundation
import Combine

public protocol ViewModel: ObservableObject {
    associatedtype State
    associatedtype Action
    
    var state: State { get }
    func trigger(_ action: Action) async
}

public extension ViewModel where Self.ObjectWillChangePublisher == ObservableObjectPublisher {
    func eraseToAnyViewModel() -> AnyViewModel<State, Action>  {
        return AnyViewModel<State, Action>(self)
    }
}
