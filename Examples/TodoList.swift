//
//  TodoList.swift
//  SwiftFlux
//
//  Created by 程信傑 on 2025/1/22.
//

import Combine
import Foundation

// MARK: - Models

struct Todo: Identifiable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdAt: Date

    init(id: UUID = UUID(), title: String, isCompleted: Bool = false, createdAt: Date = Date()) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

// MARK: - State

struct TodoState {
    var todos: [Todo] = []
    var isLoading = false
    var error: String?
    var filter: TodoFilter = .all
    var searchText: String = ""
}

enum TodoFilter {
    case all
    case active
    case completed
}

// MARK: - Action

enum TodoAction {
    // CRUD 操作
    case addTodo(String)
    case toggleTodo(UUID)
    case removeTodo(UUID)
    case updateTodoTitle(UUID, String)
    case clearCompleted

    // 過濾和搜尋
    case setFilter(TodoFilter)
    case setSearchText(String)

    // 非同步操作狀態
    case setLoading(Bool)
    case setError(String?)

    // 批次操作
    case loadTodos([Todo])
}

// MARK: - Side Effects

enum TodoEffect {
    /// 模擬從 API 載入待辦事項
    static func loadTodos() -> Effect<TodoAction> {
        .run { send in
            await send(.setLoading(true))

            do {
                // 模擬 API 延遲
                try await Task.sleep(nanoseconds: 1_500_000_000)

                // 模擬 API 回應
                let mockTodos = [
                    Todo(title: "學習 SwiftFlux"),
                    Todo(title: "實作 TodoList 範例"),
                    Todo(title: "撰寫單元測試"),
                ]

                await send(.loadTodos(mockTodos))
            } catch {
                await send(.setError("載入待辦事項失敗：\(error.localizedDescription)"))
            }

            await send(.setLoading(false))
        }
    }

    /// 模擬儲存待辦事項
    static func saveTodo(_ title: String) -> Effect<TodoAction> {
        .run { send in
            await send(.setLoading(true))

            do {
                // 模擬 API 延遲
                try await Task.sleep(nanoseconds: 500_000_000)

                // 新增待辦事項
                await send(.addTodo(title))
            } catch {
                await send(.setError("新增待辦事項失敗：\(error.localizedDescription)"))
            }

            await send(.setLoading(false))
        }
    }

    /// 模擬刪除已完成的待辦事項
    static func clearCompleted() -> Effect<TodoAction> {
        .run { send in
            await send(.setLoading(true))

            do {
                // 模擬 API 延遲
                try await Task.sleep(nanoseconds: 1_000_000_000)

                // 刪除已完成項目
                await send(.clearCompleted)
            } catch {
                await send(.setError("刪除已完成項目失敗：\(error.localizedDescription)"))
            }

            await send(.setLoading(false))
        }
    }
}

// MARK: - Store

let todoStore = Store<TodoState, TodoAction>(
    initialState: TodoState(),
    reducer: { state, action in
        switch action {
        case let .addTodo(title):
            let todo = Todo(title: title)
            state.todos.append(todo)
            return .none()

        case let .toggleTodo(id):
            if let index = state.todos.firstIndex(where: { $0.id == id }) {
                state.todos[index].isCompleted.toggle()
            }
            return .none()

        case let .removeTodo(id):
            state.todos.removeAll { $0.id == id }
            return .none()

        case let .updateTodoTitle(id, title):
            if let index = state.todos.firstIndex(where: { $0.id == id }) {
                state.todos[index].title = title
            }
            return .none()

        case .clearCompleted:
            state.todos.removeAll { $0.isCompleted }
            return .none()

        case let .setFilter(filter):
            state.filter = filter
            return .none()

        case let .setSearchText(text):
            state.searchText = text
            return .none()

        case let .setLoading(isLoading):
            state.isLoading = isLoading
            return .none()

        case let .setError(error):
            state.error = error
            return .none()

        case let .loadTodos(todos):
            state.todos = todos
            return .none()
        }
    }
)

// MARK: - View Controller

class TodoListViewController: BaseViewController<Store<TodoState, TodoAction>, TodoState, TodoAction> {
    override func viewDidLoad() {
        super.viewDidLoad()

        // 監聽狀態變更
        observe(\.todos) { [weak self] todos in
            self?.updateTodoList(todos)
        }

        observe(\.isLoading) { [weak self] isLoading in
            self?.updateLoadingState(isLoading)
        }

        observe(\.error) { [weak self] error in
            self?.showError(error)
        }

        observe(\.filter) { [weak self] filter in
            self?.updateFilterSelection(filter)
        }

        // 載入初始資料
        loadInitialData()
    }

    // MARK: - Actions

    private func loadInitialData() {
        store.send(TodoEffect.loadTodos())
    }

    func addTodoTapped(title: String) {
        store.send(TodoEffect.saveTodo(title))
    }

    func toggleTodoTapped(id: UUID) {
        store.send(.toggleTodo(id))
    }

    func removeTodoTapped(id: UUID) {
        store.send(.removeTodo(id))
    }

    func updateTodoTitleTapped(id: UUID, title: String) {
        store.send(.updateTodoTitle(id, title))
    }

    func clearCompletedTapped() {
        store.send(TodoEffect.clearCompleted())
    }

    func filterChanged(_ filter: TodoFilter) {
        store.send(.setFilter(filter))
    }

    func searchTextChanged(_ text: String) {
        store.send(.setSearchText(text))
    }

    // MARK: - UI Updates

    private func updateTodoList(_: [Todo]) {
        // 更新待辦事項列表顯示
    }

    private func updateLoadingState(_: Bool) {
        // 更新載入狀態
    }

    private func showError(_: String?) {
        // 顯示錯誤訊息
    }

    private func updateFilterSelection(_: TodoFilter) {
        // 更新過濾器選擇狀態
    }
}
