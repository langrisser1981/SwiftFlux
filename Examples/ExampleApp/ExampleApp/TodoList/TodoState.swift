// TodoState.swift
// 待辦事項清單的狀態

import Foundation
import SwiftFlux

/// 待辦事項模型
public struct TodoItem: Identifiable, Equatable {
    public let id: UUID
    public var title: String
    public var isCompleted: Bool

    public init(id: UUID = UUID(), title: String, isCompleted: Bool = false) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
    }
}

/// 待辦事項清單的狀態
public struct TodoState: Equatable {
    /// 待辦事項清單
    var items: [TodoItem]
    /// 新增待辦事項的輸入文字
    var newItemTitle: String
    /// 是否正在載入中
    var isLoading: Bool
    /// 錯誤訊息
    var errorMessage: String?

    public init(
        items: [TodoItem] = [],
        newItemTitle: String = "",
        isLoading: Bool = false,
        errorMessage: String? = nil
    ) {
        self.items = items
        self.newItemTitle = newItemTitle
        self.isLoading = isLoading
        self.errorMessage = errorMessage
    }
}

/// 待辦事項清單的操作
public enum TodoAction {
    /// 新增待辦事項
    case add
    /// 更新輸入文字
    case updateNewItemTitle(String)
    /// 切換待辦事項完成狀態
    case toggleComplete(UUID)
    /// 刪除待辦事項
    case delete(UUID)
    /// 清除已完成的待辦事項
    case clearCompleted
    /// 設定載入狀態
    case setLoading(Bool)
    /// 設定錯誤訊息
    case setError(String?)
    /// 從伺服器載入待辦事項
    case loadItems
    /// 設定待辦事項清單
    case setItems([TodoItem])
    /// 延遲儲存待辦事項
    case saveItem(TodoItem)
    /// 批次新增待辦事項
    case batchAdd([String])
}

/// 模擬 API 呼叫
private func mockAPICall() async throws -> [TodoItem] {
    // 模擬網路延遲
    try await Task.sleep(for: .seconds(1))

    // 模擬從伺服器取得的資料
    return [
        TodoItem(title: "回覆電子郵件"),
        TodoItem(title: "準備會議資料"),
        TodoItem(title: "更新專案文件"),
    ]
}

/// 模擬儲存待辦事項
private func mockSaveItem(_: TodoItem) async throws {
    // 模擬網路延遲
    try await Task.sleep(for: .milliseconds(500))

    // 模擬儲存失敗的機率
//    if Bool.random() {
//        throw NSError(domain: "TodoError", code: 1, userInfo: [
//            NSLocalizedDescriptionKey: "儲存失敗，請稍後再試",
//        ])
//    }
}

/// 待辦事項清單的 Reducer
public func todoReducer(state: inout TodoState, action: TodoAction) -> Effect<TodoAction> {
    switch action {
    case .add:
        guard !state.newItemTitle.isEmpty else { return .none() }
        let newItem = TodoItem(title: state.newItemTitle)
        state.items.append(newItem)
        state.newItemTitle = ""

        // 延遲儲存新增的待辦事項
        return .send(.saveItem(newItem))

    case let .updateNewItemTitle(title):
        state.newItemTitle = title
        return .none()

    case let .toggleComplete(id):
        if let index = state.items.firstIndex(where: { $0.id == id }) {
            state.items[index].isCompleted.toggle()
            // 延遲儲存更新的待辦事項
            return .send(.saveItem(state.items[index]))
        }
        return .none()

    case let .delete(id):
        state.items.removeAll { $0.id == id }
        return .none()

    case .clearCompleted:
        state.items.removeAll { $0.isCompleted }
        return .none()

    case let .setLoading(isLoading):
        state.isLoading = isLoading
        return .none()

    case let .setError(message):
        state.errorMessage = message
        // 自動清除錯誤訊息
        if message != nil {
            return .run { send in
                try await Task.sleep(for: .seconds(3))
                await send(.setError(nil))
            }
        }
        return .none()

    case .loadItems:
        // 從伺服器載入待辦事項
        return .combine(
            .send(.setLoading(true)),
            .run { send in
                do {
                    let items = try await mockAPICall()
                    await send(.setItems(items))
                } catch {
                    await send(.setError("載入失敗，請稍後再試"))
                }
                await send(.setLoading(false))
            }
        )

    case let .setItems(items):
        state.items = items
        return .none()

    case let .saveItem(item):
        // 延遲儲存待辦事項
        return .run { send in
            do {
                try await mockSaveItem(item)
            } catch {
                await send(.setError("儲存失敗，請稍後再試"))
            }
        }

    case let .batchAdd(titles):
        // 批次新增待辦事項
        return .combine(
            .send(.setLoading(true)),
            .run { [state] send in
                for title in titles {
                    let item = TodoItem(title: title)
                    await send(.setItems(state.items + [item]))
                    try await mockSaveItem(item)
//                    do {
//                        try await mocksaveitem(item)
//                    } catch {
//                        await send(.seterror("儲存失敗，請稍後再試"))
//                    }
                }
                await send(.setLoading(false))
            }
        )
    }
}
