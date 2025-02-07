# SwiftFlux 架構說明

## 類別關係圖

```mermaid
classDiagram
    class StoreType {
        <<interface>>
        +state: State
        +send(action: Action)
        +publisher(keyPath: KeyPath)
    }
    
    class Store~State, Action~ {
        -state: State
        -reducer: Reducer
        -cancellables: Set~AnyCancellable~
        +init(initialState: State, reducer: Reducer)
        +send(action: Action)
        +publisher(keyPath: KeyPath)
    }
    
    class Effect~Action~ {
        -actions: [Action]
        -sideEffects: [(Send) async -> Void]
        +none()
        +send(action: Action)
        +batch(actions: Action...)
        +run(operation: (Send) async -> Void)
        +combine(effects: Effect...)
    }
    
    StoreType <|.. Store
    Store --> Effect : creates
```

## 動作流程圖

```mermaid
flowchart TD
    A[建立 Store] --> B[初始化 State]
    B --> C[設定 Reducer]
    
    D[送出 Action] --> E[執行 Reducer]
    E --> F{產生 Effect}
    
    F --> G[同步 Actions]
    F --> H[非同步 SideEffects]
    
    G --> I[直接送出新的 Action]
    I --> D
    
    H --> J[執行非同步操作]
    J --> K[完成後送出新的 Action]
    K --> D
    
    L[訂閱 State 變更] --> M[透過 Publisher 監聽]
    M --> N[State 更新]
    N --> O[通知訂閱者]
```

## 處理流程說明

1. **初始化階段**
   - 建立 Store 時需提供初始 State 和 Reducer
   - Reducer 是一個將目前 State 和 Action 轉換為新 State 的函式

2. **Action 處理流程**
   - 當 `send()` 被呼叫時，會觸發 Reducer
   - Reducer 會回傳 Effect 物件
   - Effect 可以包含：
     - 同步的 Actions：立即被處理
     - 非同步的 SideEffects：在背景執行

3. **State 訂閱機制**
   - 使用 Combine framework 的 Publisher 機制
   - 可以訂閱整個 State 或特定屬性的變更
   - 當 State 更新時，所有訂閱者都會收到通知 