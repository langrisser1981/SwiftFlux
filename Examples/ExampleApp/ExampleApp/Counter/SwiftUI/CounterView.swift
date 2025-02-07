// CounterView.swift
// SwiftUI 版本的計數器視圖

import SwiftFlux
import SwiftUI

struct CounterView: View {
    @StateObject private var store: Store<CounterState, CounterAction>

    init() {
        _store = StateObject(wrappedValue: Store(
            initialState: CounterState(),
            reducer: counterReducer
        ))
    }

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("\(store.state.count)")
                    .font(.system(size: 48, weight: .bold))

                if store.state.isLoading {
                    ProgressView()
                        .controlSize(.regular)
                }
            }

            Button("增加") {
                store.send(.increment)
            }
            .buttonStyle(.borderedProminent)

            Button("減少") {
                store.send(.decrement)
            }
            .buttonStyle(.borderedProminent)

            Button("延遲增加") {
                store.send(.delayedIncrement)
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)

            Button("批次增加 5 次") {
                store.send(.batchIncrement(5))
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Button("重設") {
                store.send(.reset)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .disabled(store.state.isLoading)
    }
}

#Preview {
    CounterView()
}
