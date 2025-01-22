//
//  BaseViewController.swift
//  SwiftFlux
//
//  Created by 程信傑 on 2025/1/22.
//

import Combine
import Foundation
import UIKit

open class BaseViewController<StoreType: Store<State, Action>, State, Action>: UIViewController {
    /// The store instance
    public let store: StoreType

    /// Set of cancellables for managing subscriptions
    private var cancellables: Set<AnyCancellable> = []

    /// Initializes a view controller with a store
    /// - Parameter store: The store instance to use
    public init(store: StoreType) {
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Observes a specific property of the state
    /// - Parameters:
    ///   - keyPath: The key path of the property to observe
    ///   - onChange: The closure to execute when the value changes
    public func observe<Value: Equatable>(
        _ keyPath: KeyPath<State, Value>,
        onChange: @escaping (Value) -> Void
    ) {
        store.publisher(for: keyPath)
            .sink { value in
                onChange(value)
            }
            .store(in: &cancellables)
    }
}
