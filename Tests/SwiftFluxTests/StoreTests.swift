@testable import MyLibrary
import Testing

@Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}

@testable import SwiftFlux
import XCTest

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

    func testBasicStateManagement() {
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

    func testEffects() {
        let expectation = expectation(description: "Async effect")

        let store = Store<TestState, TestAction>(
            initialState: TestState(),
            reducer: { _, action in
                switch action {
                case .increment:
                    return .none()
                case .setText:
                    return .none()
                case .asyncAction:
                    return .run { send in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            send(.setText("Updated"))
                            expectation.fulfill()
                        }
                    }
                }
            }
        )

        store.send(.asyncAction)

        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error)
            XCTAssertEqual(store.text, "Updated")
        }
    }

    func testCombinedEffects() {
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
                    return .none()
                }
            }
        )

        store.send(.increment)

        XCTAssertEqual(store.count, 1)
        XCTAssertEqual(store.text, "Incremented")
    }
}
