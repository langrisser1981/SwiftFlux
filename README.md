# SwiftFlux

A lightweight, type-safe Redux/Flux implementation for Swift applications, focusing on simplicity and composition.

## Features
- Type-safe state management
- Composable effects with async/await support
- Powerful effect system for side effects handling
- Simple dependency injection
- Easy integration with UIKit/SwiftUI
- Thread-safe action dispatching
- Automatic main thread synchronization

## Version History

### v1.0: Basic Store Implementation
- Basic store with state and actions
- Simple reducer pattern
- Publisher support for state changes
```swift
final class Store<State, Action> {
    typealias Reducer = (State, Action) -> State
    @Published private var state: State
    private let reducer: Reducer
}
```

### v2.0: Added Middleware Support
- Introduced middleware for side effects
- Support for async operations using Combine
```swift
final class Store<State, Action> {
    typealias Reducer = (State, Action) -> State
    typealias Middleware = (State, Action) -> AnyPublisher<Action, Never>?
    @Published private var state: State
    private let reducer: Reducer
    private let middleware: Middleware
}
```

### v3.0: Added Effect Pattern
- Introduced Effect type for handling side effects
- Support for multiple actions
```swift
struct Effect {
    let actions: [Action]
    
    static func none() -> Effect
    static func send(_ action: Action) -> Effect
    static func batch(_ actions: Action...) -> Effect
}

typealias Reducer = (State, Action) -> (State, Effect)
```

### v4.0: Inout State Pattern
- Modified reducer to use inout State
- Improved performance and readability
```swift
typealias Reducer = (inout State, Action) -> Effect
```

### v5.0: Integrated Effects (Latest)
- Combined middleware and effects
- Added support for async/await
- Enhanced composability with Effect.combine
- Thread-safe action dispatching
```swift
struct Effect<Action> {
    typealias Send = @MainActor (Action) -> Void
    let actions: [Action]
    let sideEffects: [(Send) async throws -> Void]
    
    static func none() -> Effect
    static func send(_ action: Action) -> Effect
    static func batch(_ actions: Action...) -> Effect
    static func run(_ operation: @escaping (Send) async throws -> Void) -> Effect
    static func combine(_ effects: Effect...) -> Effect
}
```

## Installation

### Swift Package Manager
Add the following to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftFlux.git", from: "5.0.0")
]
```

## Basic Usage

### State and Actions
```swift
// Define your state
struct AppState {
    var count = 0
    var isLoading = false
    var error: Error?
    var data: String?
}

// Define your actions
enum AppAction {
    case increment
    case incrementAsync
    case setLoading(Bool)
    case setError(Error?)
    case setData(String)
}
```

### Reducer with Effects
```swift
let store = Store<AppState, AppAction>(
    initialState: AppState(),
    reducer: { state, action in
        switch action {
        case .increment:
            state.count += 1
            return .none()
            
        case .incrementAsync:
            state.isLoading = true
            return .run { send in
                do {
                    try await Task.sleep(nanoseconds: 1_000_000_000)
                    await send(.increment)
                    await send(.setLoading(false))
                } catch {
                    await send(.setError(error))
                }
            }
            
        case .setLoading(let isLoading):
            state.isLoading = isLoading
            return .none()
            
        case .setError(let error):
            state.error = error
            state.isLoading = false
            return .none()
            
        case .setData(let data):
            state.data = data
            return .none()
        }
    }
)
```

## Advanced Usage

### Composing Effects
```swift
// 組合多個 Effect
case .userLoggedIn(let user):
    return .combine(
        .send(.setUser(user)),
        .send(.setLoading(true)),
        .run { send in
            do {
                let preferences = try await fetchUserPreferences(user.id)
                let data = try await fetchUserData(user.id)
                await send(.setUserPreferences(preferences))
                await send(.setUserData(data))
            } catch {
                await send(.setError(error))
            }
            await send(.setLoading(false))
        }
    )
```

### SwiftUI Integration
```swift
struct CounterView: View {
    @ObservedObject var store: Store<AppState, AppAction>
    
    var body: some View {
        VStack {
            Text("Count: \(store.state.count)")
            if store.state.isLoading {
                ProgressView()
            }
            Button("Increment") {
                store.send(.increment)
            }
            Button("Async Increment") {
                store.send(.incrementAsync)
            }
        }
    }
}
```

### UIKit Integration
```swift
class CounterViewController: BaseViewController<Store<AppState, AppAction>, AppState, AppAction> {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 觀察特定狀態變化
        observe(\.count) { [weak self] count in
            self?.countLabel.text = "Count: \(count)"
        }
        
        observe(\.isLoading) { [weak self] isLoading in
            self?.loadingIndicator.isHidden = !isLoading
        }
    }
    
    @objc func incrementTapped() {
        store.send(.increment)
    }
    
    @objc func incrementAsyncTapped() {
        store.send(.incrementAsync)
    }
}
```

## Project Structure
```
SwiftFlux/
├── Sources/
│   ├── Store.swift         # 核心 Store 實作
│   ├── Effect.swift        # Effect 系統實作
│   ├── StoreType.swift     # Store 協定定義
│   └── BaseViewController.swift  # UIKit 整合基礎類別
├── Tests/
│   └── StoreTests.swift    # 單元測試
└── Examples/
    ├── Counter/           # 計數器範例
    └── TodoList/          # 待辦事項清單範例
```

## Contributing
歡迎貢獻！請隨時提交 Pull Request。

## License
本專案使用 MIT 授權條款 - 詳見 LICENSE 檔案。
