//
//  StoreType.swift
//  SwiftFlux
//
//  Created by 程信傑 on 2025/1/22.
//

import Combine
import Foundation

/// A protocol defining the core functionality of a Store
@MainActor
public protocol StoreType: ObservableObject {
    associatedtype State
    associatedtype Action

    /// The current state of the store
    var state: State { get }

    /// Sends an action to the store
    /// - Parameter action: The action to send
    func send(_ action: Action)

    /// Creates a publisher for a specific key path of the state
    /// - Parameter keyPath: The key path to observe
    /// - Returns: A publisher that emits when the specified value changes
    func publisher<Value>(for keyPath: KeyPath<State, Value>) -> AnyPublisher<Value, Never>
}
