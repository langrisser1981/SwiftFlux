//
//  Store.swift
//  SwiftFlux
//
//  Created by 程信傑 on 2025/1/22.
//

import Combine
import Foundation

@dynamicMemberLookup
public final class Store<State, Action>: StoreType {
    /// The reducer function type that handles state mutations
    public typealias Reducer = (inout State, Action) -> Effect<Action>

    /// The current state of the store
    @Published public private(set) var state: State

    /// The reducer function that handles state mutations
    private let reducer: Reducer

    /// Set of cancellables for managing subscriptions
    private var cancellables: Set<AnyCancellable> = []

    /// Initializes a new store with an initial state and reducer
    /// - Parameters:
    ///   - initialState: The initial state of the store
    ///   - reducer: The reducer function that will handle state mutations
    public init(initialState: State, reducer: @escaping Reducer) {
        self.state = initialState
        self.reducer = reducer
    }

    /// Provides dynamic member lookup for state properties
    public subscript<Value>(dynamicMember keyPath: KeyPath<State, Value>) -> Value {
        state[keyPath: keyPath]
    }

    /// Creates a publisher for a specific key path of the state
    /// - Parameter keyPath: The key path to observe
    /// - Returns: A publisher that emits when the specified value changes
    public func publisher<Value>(for keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never> {
        $state
            .map { $0[keyPath: keyPath] }
//            .removeDuplicates(by: ==)
            .eraseToAnyPublisher()
    }

    /// Sends an action to the store
    /// - Parameter action: The action to send
    public func send(_ action: Action) {
        let effect = reducer(&state, action)

        // Handle synchronous actions
        for action in effect.actions {
            self.send(action)
        }

        // Handle asynchronous side effects
        for sideEffect in effect.sideEffects {
            Task {
                do {
                    try await sideEffect { [weak self] action in
                        self?.send(action)
                    }
                } catch {
                    print("出現錯誤 ： \(error)")
                }
            }
        }
    }
}
