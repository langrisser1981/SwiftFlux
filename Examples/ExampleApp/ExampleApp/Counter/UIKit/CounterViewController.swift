// CounterViewController.swift
// UIKit 版本的計數器視圖控制器

import SwiftFlux
import UIKit

final class CounterViewController: BaseViewController<Store<CounterState, CounterAction>, CounterState, CounterAction> {
    // MARK: - UI 元件

    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 48, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var incrementButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "增加"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(incrementTapped), for: .touchUpInside)
        return button
    }()

    private lazy var decrementButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "減少"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(decrementTapped), for: .touchUpInside)
        return button
    }()

    private lazy var resetButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "重設"
        configuration.baseBackgroundColor = .systemRed
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(resetTapped), for: .touchUpInside)
        return button
    }()

    private lazy var delayedIncrementButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "延遲增加"
        configuration.baseBackgroundColor = .systemBlue
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(delayedIncrementTapped), for: .touchUpInside)
        return button
    }()

    private lazy var batchIncrementButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "批次增加 5 次"
        configuration.baseBackgroundColor = .systemGreen
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(batchIncrementTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - 生命週期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }

    // MARK: - UI 設定

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let stackView = UIStackView(arrangedSubviews: [
            countLabel,
            incrementButton,
            decrementButton,
            delayedIncrementButton,
            batchIncrementButton,
            resetButton,
        ])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        view.addSubview(loadingIndicator)

        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            loadingIndicator.centerXAnchor.constraint(equalTo: countLabel.trailingAnchor, constant: 8),
            loadingIndicator.centerYAnchor.constraint(equalTo: countLabel.centerYAnchor),
        ])
    }

    // MARK: - 資料綁定

    private func setupBindings() {
        observe(\.count) { [weak self] count in
            self?.countLabel.text = "\(count)"
        }

        observe(\.isLoading) { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
            self?.updateButtonsState(isEnabled: !isLoading)
        }
    }

    private func updateButtonsState(isEnabled: Bool) {
        incrementButton.isEnabled = isEnabled
        decrementButton.isEnabled = isEnabled
        resetButton.isEnabled = isEnabled
        delayedIncrementButton.isEnabled = isEnabled
        batchIncrementButton.isEnabled = isEnabled
    }

    // MARK: - 動作處理

    @objc private func incrementTapped() {
        store.send(.increment)
    }

    @objc private func decrementTapped() {
        store.send(.decrement)
    }

    @objc private func resetTapped() {
        store.send(.reset)
    }

    @objc private func delayedIncrementTapped() {
        store.send(.delayedIncrement)
    }

    @objc private func batchIncrementTapped() {
        store.send(.batchIncrement(5))
    }
}
