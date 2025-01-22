//
//  Counter.swift
//  SwiftFlux
//
//  Created by 程信傑 on 2025/1/22.
//

import Foundation

struct AppState {
    var count = 0
}

enum AppAction {
    case increment
}

let store = Store<AppState, AppAction>(
    initialState: AppState(),
    reducer: { state, action in
        switch action {
        case .increment:
            state.count += 1
            return .none()
        }
    }
)
class MyViewController: BaseViewController<Store<AppState, AppAction>, AppState, AppAction> {
    override func viewDidLoad() {
        super.viewDidLoad()
        observe(\.count) { [weak self] count in
            self?.updateUI(with: count)
        }
    }
}
