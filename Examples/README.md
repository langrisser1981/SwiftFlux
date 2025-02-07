# SwiftFlux 範例

這個資料夾包含了 SwiftFlux 的範例程式碼，展示如何在實際專案中使用 SwiftFlux。

## 資料夾結構

```
ExampleApp/
├── ExampleApp.swift/       # 範例應用程式
│
├── Counter/                # 計數器範例
│   ├── CounterState.swift  # 計數器的狀態和 Reducer
│   ├── SwiftUI/           # SwiftUI 實作
│   │   └── CounterView.swift
│   └── UIKit/             # UIKit 實作
│       └── CounterViewController.swift
│
└── TodoList/              # 待辦事項清單範例
    ├── TodoState.swift    # 待辦事項的狀態和 Reducer
    ├── SwiftUI/          # SwiftUI 實作
    │   └── TodoListView.swift
    └── UIKit/            # UIKit 實作
        └── TodoListViewController.swift
```

## Effect 系統說明

SwiftFlux 提供強大的 Effect 系統來處理同步和非同步的副作用：

1. **同步 Effect**
   ```swift
   // 送出單一 Action
   Effect.send(CounterAction.increment)
   
   // 批次送出多個 Action
   Effect.batch(
       CounterAction.increment,
       CounterAction.setLoading(false)
   )
   ```

2. **非同步 Effect**
   ```swift
   // 執行非同步操作
   Effect.run { send in
       do {
           let result = try await todoAPI.fetchItems()
           send(.fetchSuccess(result))
       } catch {
           send(.fetchError(error))
       }
   }
   ```

3. **組合 Effect**
   ```swift
   // 組合多個 Effect
   Effect.combine(
       Effect.send(.startLoading),
       Effect.run { send in
           let data = try await fetchData()
           send(.dataLoaded(data))
       }
   )
   ```

## 範例說明

1. 計數器範例
   - 展示基本的狀態管理
   - 包含同步和非同步操作
   - 提供 SwiftUI 和 UIKit 兩種實作
   
   ```swift
   // 計數器 Reducer 範例
   func counterReducer(state: inout CounterState, action: CounterAction) -> Effect<CounterAction> {
       switch action {
       case .increment:
           state.count += 1
           return .none()
           
       case .incrementAsync:
           return .run { send in
               try await Task.sleep(nanoseconds: 1_000_000_000)
               send(.increment)
           }
       }
   }
   ```

2. 待辦事項清單範例
   - 展示較複雜的狀態管理
   - 包含非同步 API 呼叫
   - 展示錯誤處理
   - 提供 SwiftUI 和 UIKit 兩種實作
   
   ```swift
   // 待辦事項 Reducer 範例
   func todoReducer(state: inout TodoState, action: TodoAction) -> Effect<TodoAction> {
       switch action {
       case .addTodo(let todo):
           state.todos.append(todo)
           return .run { send in
               do {
                   try await todoAPI.saveTodo(todo)
                   send(.saveSuccess)
               } catch {
                   send(.saveError(error))
               }
           }
           
       case .fetchTodos:
           return Effect.combine(
               Effect.send(.setLoading(true)),
               Effect.run { send in
                   let todos = try await todoAPI.fetchTodos()
                   send(.fetchSuccess(todos))
               }
           )
       }
   }
   ```

## 注意事項

- 範例中的非同步操作使用模擬的 API 呼叫
- UIKit 視圖使用 `UIKitWrapperView` 整合到 SwiftUI 中
- 所有範例都使用繁體中文註解和使用者介面
- Effect 系統會自動在主線程上執行 Action
