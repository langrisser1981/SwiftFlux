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

## 範例說明

1. 計數器範例
   - 展示基本的狀態管理
   - 包含同步和非同步操作
   - 提供 SwiftUI 和 UIKit 兩種實作

2. 待辦事項清單範例
   - 展示較複雜的狀態管理
   - 包含非同步 API 呼叫
   - 展示錯誤處理
   - 提供 SwiftUI 和 UIKit 兩種實作

## 注意事項

- 範例中的非同步操作使用模擬的 API 呼叫
- UIKit 視圖使用 `UIKitWrapperView` 整合到 SwiftUI 中
- 所有範例都使用繁體中文註解和使用者介面 
