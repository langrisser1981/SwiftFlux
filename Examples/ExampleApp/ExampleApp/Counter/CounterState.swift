// CounterState.swift
// 計數器的狀態

import Foundation
import SwiftFlux

public struct CounterState: Equatable {
    /// 計數器的值
    var count: Int
    /// 是否正在載入中
    var isLoading: Bool

    /// 初始化計數器狀態
    public init(count: Int = 0, isLoading: Bool = false) {
        self.count = count
        self.isLoading = isLoading
    }
}

// 計數器的操作
public enum CounterAction {
    /// 增加計數
    case increment
    /// 減少計數
    case decrement
    /// 重設計數
    case reset
    /// 延遲增加計數
    case delayedIncrement
    /// 設定載入狀態
    case setLoading(Bool)
    /// 批次增加
    case batchIncrement(Int)
}

// 計數器的 Reducer
public func counterReducer(state: inout CounterState, action: CounterAction) -> Effect<CounterAction> {
    switch action {
    case .increment:
        state.count += 1
        return .none()

    case .decrement:
        state.count -= 1
        return .none()

    case .reset:
        state.count = 0
        return .none()

    case .delayedIncrement:
        // 回傳一個包含多個 Effect 的組合
        return .combine(
            // 設定載入狀態為 true
            .send(.setLoading(true)),
            // 執行非同步操作
            .run { send in
                try await Task.sleep(for: .seconds(1))
                await send(.increment)
                await send(.setLoading(false))
            }
        )

    case let .setLoading(isLoading):
        state.isLoading = isLoading
        return .none()

    case let .batchIncrement(times):
        // 回傳一個執行多次增加的非同步操作
        return .run { send in
            for _ in 0 ..< times {
                await send(.increment)
                try await Task.sleep(for: .milliseconds(100))
            }
        }
    }
}
