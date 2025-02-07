//
//  Counter.swift
//  SwiftFlux
//
//  Created by 程信傑 on 2025/1/22.
//

import Combine
import Foundation

// MARK: - State

struct AppState {
    var count = 0
    var isLoading = false
    var error: String?
    var lastUpdated: Date?
}

// MARK: - Action

enum AppAction {
    case increment
    case decrement
    case incrementByAmount(Int)
    case reset
    case setLoading(Bool)
    case setError(String?)
    case updateTimestamp
}

// MARK: - Side Effects

enum CounterEffect {
    /// 模擬非同步增加數值
    static func asyncIncrement(by amount: Int) -> Effect<AppAction> {
        .run { send in
            // 開始載入
            await send(.setLoading(true))

            do {
                // 模擬 API 延遲
                try await Task.sleep(nanoseconds: 1_000_000_000)

                // 送出增加數值的 action
                await send(.incrementByAmount(amount))
                await send(.updateTimestamp)
            } catch {
                await send(.setError("非同步操作失敗：\(error.localizedDescription)"))
            }

            // 結束載入
            await send(.setLoading(false))
        }
    }

    /// 重設計數器並更新時間戳記
    static func resetWithTimestamp() -> Effect<AppAction> {
        .combine(
            .send(.reset),
            .send(.updateTimestamp)
        )
    }
}

// MARK: - Store

let store = Store<AppState, AppAction>(
    initialState: AppState(),
    reducer: { state, action in
        switch action {
        case .increment:
            state.count += 1
            return .none()

        case .decrement:
            state.count -= 1
            return .none()

        case let .incrementByAmount(amount):
            state.count += amount
            return .none()

        case .reset:
            state.count = 0
            state.error = nil
            return .none()

        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return .none()

        case let .setError(error):
            state.error = error
            return .none()

        case .updateTimestamp:
            state.lastUpdated = Date()
            return .none()
        }
    }
)

// MARK: - View Controller

class CounterViewController: BaseViewController<Store<AppState, AppAction>, AppState, AppAction> {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 監聽多個狀態變更
        observe(\.count) { [weak self] count in
            self?.updateCountLabel(count)
        }

        observe(\.isLoading) { [weak self] isLoading in
            self?.updateLoadingState(isLoading)
        }

        observe(\.error) { [weak self] error in
            self?.showError(error)
        }

        observe(\.lastUpdated) { [weak self] date in
            self?.updateTimestamp(date)
        }
    }

    // MARK: - Actions

    /// 一般同步增加
    func incrementTapped() {
        store.send(.increment)
    }

    /// 一般同步減少
    func decrementTapped() {
        store.send(.decrement)
    }

    /// 非同步增加
    func asyncIncrementTapped() {
        store.send(CounterEffect.asyncIncrement(by: 5))
    }

    /// 重設計數器
    func resetTapped() {
        store.send(CounterEffect.resetWithTimestamp())
    }

    // MARK: - UI Updates

    private func updateCountLabel(_: Int) {
        // 更新計數器顯示
    }

    private func updateLoadingState(_: Bool) {
        // 更新載入狀態
    }

    private func showError(_: String?) {
        // 顯示錯誤訊息
    }

    private func updateTimestamp(_: Date?) {
        // 更新最後更新時間
    }
}
