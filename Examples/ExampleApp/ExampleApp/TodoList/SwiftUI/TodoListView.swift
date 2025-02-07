// TodoListView.swift
// SwiftUI 版本的待辦事項清單視圖

import SwiftFlux
import SwiftUI

struct TodoListView: View {
    @StateObject private var store: Store<TodoState, TodoAction>

    init() {
        _store = StateObject(wrappedValue: Store(
            initialState: TodoState(),
            reducer: todoReducer
        ))
    }

    private var isEnabled: Bool {
        !store.state.isLoading
    }

    var body: some View {
        NavigationView {
            VStack {
                // 錯誤訊息
                if let errorMessage = store.state.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.horizontal)
                }

                // 輸入區域
                HStack {
                    TextField("新增待辦事項...", text: Binding(
                        get: { store.state.newItemTitle },
                        set: { store.send(.updateNewItemTitle($0)) }
                    ))
                    .textFieldStyle(.roundedBorder)
                    .disabled(!isEnabled)

                    Button("新增") {
                        store.send(.add)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isEnabled)

                    if store.state.isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
                .padding(.horizontal)

                // 待辦事項清單
                List {
                    ForEach(store.state.items) { item in
                        HStack {
                            Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(item.isCompleted ? .green : .gray)

                            Text(item.title)
                                .strikethrough(item.isCompleted)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            store.send(.toggleComplete(item.id))
                        }
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            store.send(.delete(store.state.items[index].id))
                        }
                    }
                }
                .disabled(!isEnabled)
                .overlay {
                    if store.state.items.isEmpty {
                        ContentUnavailableView(
                            label: {
                                Label(
                                    "沒有待辦事項",
                                    systemImage: "list.bullet.clipboard"
                                )
                            },
                            description: {
                                Text("點擊「從伺服器載入」或新增待辦事項")
                            }
                        )
                    }
                }

                // 動作按鈕
                VStack(spacing: 8) {
                    Button("從伺服器載入") {
                        store.send(.loadItems)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button("批次新增範例") {
                        store.send(.batchAdd([
                            "檢查電子郵件",
                            "撰寫報告",
                            "安排會議",
                            "更新文件",
                            "回覆訊息",
                        ]))
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)

                    Button("清除已完成") {
                        store.send(.clearCompleted)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                }
                .disabled(!isEnabled)
                .padding()
            }
            .navigationTitle("待辦事項")
        }
        .task {
            // 載入初始資料
            store.send(.loadItems)
        }
    }
}

#Preview {
    TodoListView()
}
