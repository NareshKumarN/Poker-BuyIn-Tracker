//
//  HighHandViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//


import UIKit

class HighHandViewController: UIViewController {
    private var session: Session
    private let completion: (Session) -> Void
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let handTypes = ["Full House", "Four of a Kind", "Straight Flush", "Royal Flush"]

    init(session: Session, completion: @escaping (Session) -> Void) {
        self.session = session
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "High Hand"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(save))

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HandTypeCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PlayerCell")

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func cancel() {
        dismiss(animated: true)
    }

    @objc private func save() {
        completion(session)
        dismiss(animated: true)
    }

    private func showHandForm(for handType: String) {
        switch handType {
        case "Full House":
            showFullHouseForm()
        case "Four of a Kind":
            showQuadsForm()
        case "Straight Flush":
            showStraightFlushForm()
        case "Royal Flush":
            session.highHandType = handType
            session.highHandCards = "AKQJT"
            tableView.reloadData()
        default:
            break
        }
    }

    private func showFullHouseForm() {
        let alert = UIAlertController(title: "Full House", message: "Enter cards", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Three of a kind (e.g., K)" }
        alert.addTextField { $0.placeholder = "Pair (e.g., 2)" }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let trips = alert.textFields?[0].text?.uppercased(),
                  let pair = alert.textFields?[1].text?.uppercased(),
                  !trips.isEmpty, !pair.isEmpty else { return }

            self.session.highHandType = "Full House"
            self.session.highHandCards = "\(trips)\(trips)\(trips)\(pair)\(pair)"
            self.tableView.reloadData()
        })

        present(alert, animated: true)
    }

    private func showQuadsForm() {
        let alert = UIAlertController(title: "Four of a Kind", message: "Enter cards", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Four of a kind (e.g., K)" }
        alert.addTextField { $0.placeholder = "Kicker (e.g., 2)" }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let quads = alert.textFields?[0].text?.uppercased(),
                  let kicker = alert.textFields?[1].text?.uppercased(),
                  !quads.isEmpty, !kicker.isEmpty else { return }

            self.session.highHandType = "Four of a Kind"
            self.session.highHandCards = "\(quads)\(quads)\(quads)\(quads)\(kicker)"
            self.tableView.reloadData()
        })

        present(alert, animated: true)
    }

    private func showStraightFlushForm() {
        let alert = UIAlertController(title: "Straight Flush", message: "Enter range", preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "Low card (e.g., 4)" }
        alert.addTextField { $0.placeholder = "High card (e.g., 8)" }

        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            guard let low = alert.textFields?[0].text?.uppercased(),
                  let high = alert.textFields?[1].text?.uppercased(),
                  !low.isEmpty, !high.isEmpty else { return }

            self.session.highHandType = "Straight Flush"
            self.session.highHandCards = "\(low)\(high) Straight"
            self.tableView.reloadData()
        })

        present(alert, animated: true)
    }
}

extension HighHandViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return handTypes.count
        } else {
            return session.playerIds.count
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Hand Type" : "Winner"
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "HandTypeCell", for: indexPath)
            let handType = handTypes[indexPath.row]
            cell.textLabel?.text = handType
            cell.accessoryType = handType == session.highHandType ? .checkmark : .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
            let playerId = session.playerIds[indexPath.row]
            let player = DataStore.shared.users.first { $0.id == playerId }!
            cell.textLabel?.text = player.name
            cell.accessoryType = session.highHandOwner == playerId ? .checkmark : .none
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 0 {
            let handType = handTypes[indexPath.row]
            showHandForm(for: handType)
        } else {
            let playerId = session.playerIds[indexPath.row]
            session.highHandOwner = playerId
            tableView.reloadSections([1], with: .none)
        }
    }
}
