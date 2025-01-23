//
//  Effect.swift
//  SwiftFlux
//
//  Created by 程信傑 on 2025/1/22.
//

import Foundation

public struct Effect<Action> {
    /// Type alias for the action sending function
    public typealias Send = @MainActor (Action) -> Void

    /// Synchronous actions to be executed
    let actions: [Action]

    /// Asynchronous side effects to be executed
    let sideEffects: [(Send) async throws -> Void]

    private init(actions: [Action] = [], sideEffects: [(Send) async throws -> Void] = []) {
        self.actions = actions
        self.sideEffects = sideEffects
    }

    /// Creates an effect that does nothing
    /// - Returns: An empty effect
    public static func none() -> Effect {
        Effect()
    }

    /// Creates an effect that sends a single action
    /// - Parameter action: The action to send
    /// - Returns: An effect containing the action
    public static func send(_ action: Action) -> Effect {
        Effect(actions: [action])
    }

    /// Creates an effect that sends multiple actions
    /// - Parameter actions: The actions to send
    /// - Returns: An effect containing the actions
    public static func batch(_ actions: Action...) -> Effect {
        Effect(actions: actions)
    }

    /// Creates an effect that performs an asynchronous operation
    /// - Parameter operation: The async operation to perform
    /// - Returns: An effect containing the operation
    public static func run(_ operation: @escaping (Send) async throws -> Void) -> Effect {
        Effect(sideEffects: [operation])
    }

    /// Combines multiple effects into a single effect
    /// - Parameter effects: The effects to combine
    /// - Returns: A combined effect
    public static func combine(_ effects: Effect...) -> Effect {
        Effect(
            actions: effects.flatMap { $0.actions },
            sideEffects: effects.flatMap { $0.sideEffects }
        )
    }
}
