//
//  PlayerSelectionViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//


import UIKit

class PlayerSelectionViewController: UIViewController {
        private let tableView = UITableView()
        private let store = DataStore.shared
        private var selectedPlayers: Set<UUID>
        private let completion: (Set<UUID>) -> Void

        init(selectedPlayers: Set<UUID>, completion: @escaping (Set<UUID>) -> Void) {
            self.selectedPlayers = selectedPlayers
            self.completion = completion
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) { fatalError() }

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            tableView.reloadData()
        }

        private func setupUI() {
            view.backgroundColor = .systemBackground
            title = "Select Players"

            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(done))
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add Player", style: .plain, target: self, action: #selector(addPlayer))

            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")
            tableView.allowsMultipleSelection = true

            view.addSubview(tableView)
            tableView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }

        @objc private func done() {
            completion(selectedPlayers)
            navigationController?.popViewController(animated: true)
        }

        @objc private func addPlayer() {
            let alert = UIAlertController(title: "New Player", message: nil, preferredStyle: .alert)
            alert.addTextField { $0.placeholder = "Name" }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
                if let name = alert.textFields?.first?.text, !name.isEmpty {
                    self.store.addUser(name: name)
                    self.tableView.reloadData()
                }
            })
            present(alert, animated: true)
        }
    }

extension PlayerSelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
        let player = store.users[indexPath.row]
        cell.textLabel?.text = player.name
        cell.accessoryType = selectedPlayers.contains(player.id) ? .checkmark : .none
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let player = store.users[indexPath.row]

        if selectedPlayers.contains(player.id) {
            selectedPlayers.remove(player.id)
        } else {
            selectedPlayers.insert(player.id)
        }

        tableView.reloadRows(at: [indexPath], with: .none)
    }
}
