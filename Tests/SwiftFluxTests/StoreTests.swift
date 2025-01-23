@testable import SwiftFlux
import Testing

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

import XCTest

@MainActor
final class StoreTests: XCTestCase {
    struct TestState: Equatable {
        var count: Int = 0
        var text: String = ""
    }

    enum TestAction {
        case increment
        case setText(String)
        case asyncAction
    }

    func testBasicStateManagement() async {
        let store = Store<TestState, TestAction>(
            initialState: TestState(),
            reducer: { state, action in
                switch action {
                case .increment:
                    state.count += 1
                    return .none()
                case .setText(let text):
                    state.text = text
                    return .none()
                case .asyncAction:
                    return .none()
                }
            }
        )

        XCTAssertEqual(store.count, 0)
        store.send(.increment)
        XCTAssertEqual(store.count, 1)
    }

    func testFetchData() async {
        let myClass = MyClass()

        let expectation = XCTestExpectation(description: "fetchData completion called")

        var result: String?
        myClass.fetchData { data in
            Task { @MainActor in
                result = data
                expectation.fulfill()
            }
        }

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(result, "Hello, World!")
    }

    func testEffects() async {
        let expectation = expectation(description: "Async effect")

        let store = Store<TestState, TestAction>(
            initialState: TestState(),
            reducer: { state, action in
                switch action {
                case .increment:
                    return .none()
                case .setText(let text):
                    state.text = text
                    return .none()
                case .asyncAction:
                    return .run { send in
                        if #available(iOS 16.0, *) {
                            try? await Task.sleep(for: .seconds(0.1))
                        } else {
                            // Fallback on earlier versions
                            try? await Task.sleep(nanoseconds: 1_000_000_000)
                        }

                        send(.setText("Updated"))
                        expectation.fulfill()
                    }
                }
            }
        )

        store.send(.asyncAction)

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(store.text, "Updated")
    }

    func testCombinedEffects() async {
        let expectation = expectation(description: "Combines multiple effects ")

        let store = Store<TestState, TestAction>(
            initialState: TestState(),
            reducer: { state, action in
                switch action {
                case .increment:
                    state.count += 1
                    return .send(.setText("Incremented"))
                case .setText(let text):
                    state.text = text
                    return .none()
                case .asyncAction:
                    return .combine(
                        .send(.increment),
                        .run { send in
                            try? await Task.sleep(nanoseconds: 1_000_000_000)

                            send(.setText("Updated"))
                        },
                        .run { send in
                            try? await Task.sleep(nanoseconds: 1_000_000_000)

                            send(.setText("Updated"))
                            expectation.fulfill()
                        }
                    )
                }
            }
        )

        XCTAssertEqual(store.count, 0)
        store.send(.asyncAction)

        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.text, "Incremented")

        await fulfillment(of: [expectation], timeout: 3.0)
        XCTAssertEqual(store.text, "Updated")
    }
}

@MainActor
class MyClass {
    func fetchData(completion: @escaping @Sendable (String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion("Hello, World!")
        }
    }
}
