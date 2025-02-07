//
//  ContentView.swift
//  ExampleApp
//
//  Created by 程信傑 on 2025/2/7.
//

import SwiftFlux
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section("計數器範例") {
                    NavigationLink("SwiftUI 版本") {
                        CounterView()
                    }

                    NavigationLink("UIKit 版本") {
                        UIKitWrapperView {
                            CounterViewController(store: Store(
                                initialState: CounterState(),
                                reducer: counterReducer
                            ))
                        }
                    }
                }

                Section("待辦事項清單範例") {
                    NavigationLink("SwiftUI 版本") {
                        TodoListView()
                    }

                    NavigationLink("UIKit 版本") {
                        UIKitWrapperView {
                            TodoListViewController(store: Store(
                                initialState: TodoState(),
                                reducer: todoReducer
                            ))
                        }
                    }
                }
            }
            .navigationTitle("SwiftFlux 範例")
        }
    }
}

/// 包裝 UIViewController 的 SwiftUI View
struct UIKitWrapperView<ViewController: UIViewController>: UIViewControllerRepresentable {
    let viewController: () -> ViewController

    init(_ viewController: @escaping () -> ViewController) {
        self.viewController = viewController
    }

    func makeUIViewController(context _: Context) -> ViewController {
        viewController()
    }

    func updateUIViewController(_: ViewController, context _: Context) {}
}

#Preview {
    ContentView()
}
