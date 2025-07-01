//
//  PlayerDetailViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//

import UIKit
import Combine

class PlayerDetailViewController: UIViewController {
    private let player: Player
    private var session: Session
    private let store = DataStore.shared
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private var cancellables = Set<AnyCancellable>()

    init(player: Player, session: Session) {
        self.player = player
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = player.name
        view.backgroundColor = .systemGroupedBackground

        setupTable()
        bindStore()
    }

    private func bindStore() {
        store.$sessions
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                guard let self = self,
                      let updated = self.store.sessions.first(where: { $0.id == self.session.id })
                else { return }
                self.session = updated
                self.tableView.reloadData()
            }
            .store(in: &cancellables)
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    @objc private func editAdditionalBuyIns(for pid: UUID) {
        let alert = UIAlertController(title: "Additional Buy‑ins",
                                      message: "Enter new count",
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.keyboardType = .numberPad
            $0.text = "\(self.session.additionalBuyIns[pid] ?? 0)"
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text,
               let newCount = Int(text) {
                self.session.additionalBuyIns[pid] = newCount
                self.store.updateSession(self.session)
            }
        })
        present(alert, animated: true)
    }

    @objc private func editFinalChips(for pid: UUID) {
        let alert = UIAlertController(title: "Final Chips",
                                      message: "Enter final chip amount",
                                      preferredStyle: .alert)
        alert.addTextField {
            $0.keyboardType = .decimalPad
            if let c = self.session.finalChips[pid] ?? nil {
                $0.text = String(format: "%.2f", c)
            }
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
            if let text = alert.textFields?.first?.text,
               let value = Double(text) {
                self.session.finalChips[pid] = value
                self.store.updateSession(self.session)
            }
        })
        present(alert, animated: true)
    }
}

extension PlayerDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }
    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int { 5 }

    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let id = "DetailCell"
        let cell = tv.dequeueReusableCell(withIdentifier: id)
            ?? UITableViewCell(style: .value1, reuseIdentifier: id)
        cell.selectionStyle = .none

        let pid = player.id
        let first       = session.firstBuyIn
        let addCount    = session.additionalBuyIns[pid] ?? 0
        let addTotal    = Double(addCount * session.secondBuyIn)
        let totalBuyIns = Double(first) + addTotal
        let chipsOpt    = session.finalChips[pid] ?? nil
        let chipsVal    = chipsOpt ?? 0.0

        switch ip.row {
        case 0:
            cell.textLabel?.text       = "First Buy‑in"
            cell.detailTextLabel?.text = String(format: "$%.2f", Double(first))
        case 1:
            cell.textLabel?.text       = "Additional Buy‑ins"
            cell.detailTextLabel?.text = String(
                format: "%d × $%.2f = $%.2f",
                addCount,
                Double(session.secondBuyIn),
                addTotal
            )
            cell.selectionStyle = .default
        case 2:
            cell.textLabel?.text = "Final Chips"
            if let c = chipsOpt {
                cell.detailTextLabel?.text = String(format: "$%.2f", c)
            } else {
                cell.detailTextLabel?.text = "Not set"
            }
            cell.selectionStyle = .default
        case 3:
            cell.textLabel?.text       = "High Hand Prize"
            let prize = (session.highHandOwner == pid) ? session.highHandValue : 0.0
            cell.detailTextLabel?.text = prize > 0
                ? String(format: "$%.2f", prize)
                : "—"
        case 4:
            cell.textLabel?.text = "Net Profit"
            let prize  = (session.highHandOwner == pid) ? session.highHandValue : 0.0
            let net    = chipsVal + prize - totalBuyIns
            let fmt    = net >= 0
                ? String(format: "$%.2f", net)
                : String(format: "-$%.2f", abs(net))
            cell.detailTextLabel?.text = fmt
        default:
            break
        }
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: true)
        let pid = player.id

        switch ip.row {
        case 1:
            editAdditionalBuyIns(for: pid)
        case 2:
            editFinalChips(for: pid)
        default:
            break
        }
    }
}
