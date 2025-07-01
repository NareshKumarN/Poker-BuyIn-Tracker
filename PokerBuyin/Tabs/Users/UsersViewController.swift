//
//  UsersViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR - Vendor on 6/30/25.
//


import UIKit
import UIKit

class UsersViewController: UITableViewController {
    private let store = DataStore.shared
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Players"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addUser)
        )
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    override func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.users.count
    }
    override func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "UserCell", for: ip)
        cell.textLabel?.text = store.users[ip.row].name
        return cell
    }
    override func tableView(
      _ tv: UITableView,
      commit editingStyle: UITableViewCell.EditingStyle,
      forRowAt ip: IndexPath
    ) {
        if editingStyle == .delete {
            store.deleteUser(id: store.users[ip.row].id)
            tableView.deleteRows(at: [ip], with: .automatic)
        }
    }
    @objc private func addUser() {
        let ac = UIAlertController(title: "New Player", message: nil, preferredStyle: .alert)
        ac.addTextField { $0.placeholder = "Name" }
        ac.addAction(.init(title: "Cancel", style: .cancel))
        ac.addAction(.init(title: "Add", style: .default) { _ in
            if let name = ac.textFields?.first?.text, !name.isEmpty {
                self.store.addUser(name: name)
                self.tableView.reloadData()
            }
        })
        present(ac, animated: true)
    }
}