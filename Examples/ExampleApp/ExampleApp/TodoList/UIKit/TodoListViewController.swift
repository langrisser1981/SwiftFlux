// TodoListViewController.swift
// UIKit 版本的待辦事項清單視圖控制器

import SwiftFlux
import UIKit

final class TodoListViewController: BaseViewController<Store<TodoState, TodoAction>, TodoState, TodoAction> {
    // MARK: - UI 元件

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "新增待辦事項..."
        textField.borderStyle = .roundedRect
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private lazy var addButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "新增"
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var clearCompletedButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "清除已完成"
        configuration.baseBackgroundColor = .systemRed
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(clearCompletedTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loadItemsButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "從伺服器載入"
        configuration.baseBackgroundColor = .systemBlue
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(loadItemsTapped), for: .touchUpInside)
        return button
    }()

    private lazy var batchAddButton: UIButton = {
        var configuration = UIButton.Configuration.filled()
        configuration.title = "批次新增範例"
        configuration.baseBackgroundColor = .systemGreen
        let button = UIButton(configuration: configuration)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(batchAddTapped), for: .touchUpInside)
        return button
    }()

    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemRed
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - 生命週期

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()

        // 載入初始資料
        store.send(.loadItems)
    }

    // MARK: - UI 設定

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "待辦事項"

        let inputStackView = UIStackView(arrangedSubviews: [inputTextField, addButton])
        inputStackView.spacing = 8
        inputStackView.translatesAutoresizingMaskIntoConstraints = false

        let actionStackView = UIStackView(arrangedSubviews: [loadItemsButton, batchAddButton, clearCompletedButton])
        actionStackView.axis = .vertical
        actionStackView.spacing = 8
        actionStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(inputStackView)
        view.addSubview(tableView)
        view.addSubview(actionStackView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            inputStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            inputStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            inputStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            loadingIndicator.centerYAnchor.constraint(equalTo: inputStackView.centerYAnchor),
            loadingIndicator.trailingAnchor.constraint(equalTo: inputStackView.trailingAnchor, constant: -8),

            errorLabel.topAnchor.constraint(equalTo: inputStackView.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: actionStackView.topAnchor, constant: -8),

            actionStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            actionStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            actionStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
        ])
    }

    // MARK: - 資料綁定

    private func setupBindings() {
        observe(\.items) { [weak self] _ in
            self?.tableView.reloadData()
        }

        observe(\.newItemTitle) { [weak self] title in
            self?.inputTextField.text = title
        }

        observe(\.isLoading) { [weak self] isLoading in
            if isLoading {
                self?.loadingIndicator.startAnimating()
            } else {
                self?.loadingIndicator.stopAnimating()
            }
            self?.updateButtonsState(isEnabled: !isLoading)
        }

        observe(\.errorMessage) { [weak self] message in
            self?.errorLabel.text = message
            self?.errorLabel.isHidden = message == nil
        }
    }

    private func updateButtonsState(isEnabled: Bool) {
        addButton.isEnabled = isEnabled
        clearCompletedButton.isEnabled = isEnabled
        loadItemsButton.isEnabled = isEnabled
        batchAddButton.isEnabled = isEnabled
        inputTextField.isEnabled = isEnabled
    }

    // MARK: - 動作處理

    @objc private func addButtonTapped() {
        store.send(.add)
    }

    @objc private func clearCompletedTapped() {
        store.send(.clearCompleted)
    }

    @objc private func loadItemsTapped() {
        store.send(.loadItems)
    }

    @objc private func batchAddTapped() {
        store.send(.batchAdd([
            "檢查電子郵件",
            "撰寫報告",
            "安排會議",
            "更新文件",
            "回覆訊息",
        ]))
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension TodoListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        store.state.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let item = store.state.items[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = item.title
//        content.textProperties.strikethrough = item.isCompleted
        cell.contentConfiguration = content
        cell.accessoryType = item.isCompleted ? .checkmark : .none

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = store.state.items[indexPath.row]
        store.send(.toggleComplete(item.id))
    }

    func tableView(_: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let item = store.state.items[indexPath.row]
            store.send(.delete(item.id))
        }
    }
}

// MARK: - UITextFieldDelegate

extension TodoListViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let updatedText = ((textField.text ?? "") as NSString).replacingCharacters(in: range, with: string)
        store.send(.updateNewItemTitle(updatedText))
        return true
    }

    func textFieldShouldReturn(_: UITextField) -> Bool {
        store.send(.add)
        return true
    }
}
