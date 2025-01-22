# SwiftFlux

A lightweight, type-safe Redux/Flux implementation for Swift applications, focusing on simplicity and composition.

## Features
- Type-safe state management
- Composable effects
- Support for async operations
- Simple dependency injection
- Easy integration with UIKit/SwiftUI

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
```swift
struct Effect {
    typealias Send = (Action) -> Void
    let actions: [Action]
    let sideEffects: [(Send) -> Void]
    
    static func none() -> Effect
    static func send(_ action: Action) -> Effect
    static func batch(_ actions: Action...) -> Effect
    static func run(_ operation: @escaping (Send) -> Void) -> Effect
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

```swift
// Define your state
struct AppState {
    var count = 0
    var data = ""
}

// Define your actions
enum AppAction {
    case increment
    case fetchData
    case setData(String)
}

// Create the store
let store = Store<AppState, AppAction>(
    initialState: AppState(),
    reducer: { state, action in
        switch action {
        case .increment:
            state.count += 1
            return .none()
            
        case .fetchData:
            return .combine(
                .send(.setData("Loading...")),
                .run { send in
                    Task {
                        let data = try await fetchData()
                        send(.setData(data))
                    }
                }
            )
            
        case .setData(let data):
            state.data = data
            return .none()
        }
    }
)
```

## Advanced Usage

### Combining Effects
```swift
case .userLoggedIn(let user):
    return .combine(
        .send(.setUser(user)),
        .send(.loadUserPreferences),
        .run { send in
            Task {
                let data = try await fetchUserData()
                send(.setUserData(data))
            }
        }
    )
```

### View Controller Integration
```swift
class MyViewController: BaseViewController<Store<AppState, AppAction>, AppState, AppAction> {
    override func viewDidLoad() {
        super.viewDidLoad()
        observe(\.count) { [weak self] count in
            self?.updateUI(with: count)
        }
    }
}
```

## Project Structure
```
SwiftFlux/
├── Sources/
│   ├── Store.swift
│   ├── Effect.swift
│   ├── StoreType.swift
│   └── BaseViewController.swift
├── Tests/
│   └── StoreTests.swift
└── Examples/
    ├── Counter/
    └── TodoList/
```

## Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## License
This project is licensed under the MIT License - see the LICENSE file for details.
