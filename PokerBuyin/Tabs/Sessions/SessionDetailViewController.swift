//
//  SessionDetailViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR - Vendor on 6/30/25.
//


import UIKit
import Combine

class SessionDetailViewController: UIViewController {
    // MARK: – Properties

    var session: Session
    private let isEditable: Bool
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let store = DataStore.shared
    private let highHandHeaderView = HighHandHeaderView()
    private var cancellables = Set<AnyCancellable>()

    // MARK: – Init

    /// - Parameters:
    ///   - session: the session to display
    ///   - isEditable: if false, hides “Add Player” and prevents changes
    init(session: Session, isEditable: Bool = false) {
        self.session = session
        self.isEditable = isEditable
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    // MARK: – Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Session"
        view.backgroundColor = .systemGroupedBackground

        setupTable()
        updateHighHandDisplay()
        bindStore()
    }

    // MARK: – Setup

    private func bindStore() {
        // refresh UI if session data changes
        store.$sessions
          .receive(on: RunLoop.main)
          .sink { [weak self] _ in
            guard let self = self else { return }
            // update header
            self.updateHighHandDisplay()
            // reload player rows
            self.tableView.reloadData()
          }
          .store(in: &cancellables)
    }

    private func setupTable() {
        tableView.dataSource = self
        tableView.delegate   = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear

        // register nothing — we'll create detail cells in code

        // ── HEADER ──
        highHandHeaderView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 120)
        highHandHeaderView.isUserInteractionEnabled = true
        if isEditable {
            let tap = UITapGestureRecognizer(target: self, action: #selector(editHighHand))
            highHandHeaderView.addGestureRecognizer(tap)
        }

        tableView.tableHeaderView = highHandHeaderView

        // ── FOOTER (only if editable) ──
        if isEditable {
            let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 60))
            let addBtn = UIButton(type: .system)
            addBtn.setTitle("Add Player", for: .normal)
            addBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
            addBtn.backgroundColor = .systemBlue
            addBtn.setTitleColor(.white, for: .normal)
            addBtn.layer.cornerRadius = 8
            addBtn.addTarget(self, action: #selector(addPlayerTapped), for: .touchUpInside)
            footer.addSubview(addBtn)
            addBtn.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                addBtn.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
                addBtn.centerYAnchor.constraint(equalTo: footer.centerYAnchor),
                addBtn.leadingAnchor.constraint(equalTo: footer.leadingAnchor, constant: 20),
                addBtn.trailingAnchor.constraint(equalTo: footer.trailingAnchor, constant: -20),
                addBtn.heightAnchor.constraint(equalToConstant: 40)
            ])
            tableView.tableFooterView = footer
        }

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    func update(with session: Session) {
        self.session = session
        updateHighHandDisplay()
        tableView.reloadData()
    }

    private func updateHighHandDisplay() {
        highHandHeaderView.configure(with: session)
    }

    // MARK: – Actions

    @objc private func editHighHand() {
        let vc = HighHandViewController(session: session) { [weak self] updated in
            guard let self = self else { return }
            self.session = updated
            self.store.updateSession(updated)
        }
        present(UINavigationController(rootViewController: vc), animated: true)
    }

    @objc private func addPlayerTapped() {
        let existing = Set(session.playerIds)
        let picker = PlayerSelectionViewController(selectedPlayers: existing) { [weak self] picked in
            guard let self = self else { return }
            let newOnes = picked.subtracting(existing)
            guard !newOnes.isEmpty else { return }
            self.session.playerIds.append(contentsOf: newOnes)
            self.store.updateSession(self.session)
        }
        navigationController?.pushViewController(picker, animated: true)
    }
}

// MARK: – Table Data Source & Delegate

extension SessionDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 1 }

    func tableView(_ tv: UITableView, numberOfRowsInSection section: Int) -> Int {
        session.playerIds.count
    }

    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        // reuse PlayerCardCell for each player
        let cell = tv.dequeueReusableCell(
            withIdentifier: "PlayerCardCell"
        ) as? PlayerCardCell
        ?? PlayerCardCell(style: .default, reuseIdentifier: "PlayerCardCell")

        let pid = session.playerIds[ip.row]
        let player = store.users.first { $0.id == pid }!
        cell.configure(with: player, session: session)
//        cell.delegate = self
        cell.isUserInteractionEnabled = isEditable
        return cell
    }

    func tableView(_ tv: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        120
    }

    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: true)
        let pid = session.playerIds[ip.row]
        let player = store.users.first { $0.id == pid }!
        let detail = PlayerDetailViewController(player: player, session: session)
        navigationController?.pushViewController(detail, animated: true)
    }
}

extension SessionDetailViewController {
  // Swipe left → confirm add buy‑in
    func tableView(_ tv: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
      guard isEditable else { return nil }
      let playerId = session.playerIds[indexPath.row]

      let confirm = UIContextualAction(style: .normal, title: "Buy‑in") { [weak self] action, view, completion in
        // 1️⃣ Tell the table “we handled it” so it can animate closed:
        completion(true)

        // 2️⃣ Then present your confirmation alert:
        guard let self = self else { return }
        let alert = UIAlertController(
          title: "Add Buy‑in?",
          message: "One more buy‑in for this player?",
          preferredStyle: .alert
        )
          alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completion(false)
          })
        alert.addAction(UIAlertAction(title: "Add", style: .default) { _ in
          self.session.additionalBuyIns[playerId, default: 0] += 1
          self.store.updateSession(self.session)
        })
        self.present(alert, animated: true)
      }
      confirm.backgroundColor = .systemBlue
      return UISwipeActionsConfiguration(actions: [confirm])
    }

  // Swipe right → set final chips (unchanged)
  func tableView(_ tableView: UITableView,
                 leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
  ) -> UISwipeActionsConfiguration? {
    guard isEditable else { return nil }
    let playerId = session.playerIds[indexPath.row]

    let setFinal = UIContextualAction(style: .normal, title: "Final") { [weak self] action, view, completion in
      guard let self = self else {
        completion(false)
        return
      }
      let alert = UIAlertController(
        title: "Final Chips",
        message: "Enter final chip amount",
        preferredStyle: .alert
      )
      alert.addTextField {
        $0.keyboardType = .decimalPad
        $0.placeholder = "Amount"
        if let c = self.session.finalChips[playerId] ?? nil {
          $0.text = String(format: "%.2f", c)
        }
      }
      alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
        completion(false)
      })
      alert.addAction(UIAlertAction(title: "Save", style: .default) { _ in
        if let text = alert.textFields?.first?.text,
           let amt = Double(text) {
          self.session.finalChips[playerId] = amt
          self.store.updateSession(self.session)
          completion(true)
        } else {
          completion(false)
        }
      })
      self.present(alert, animated: true)
    }
    setFinal.backgroundColor = .systemGreen

    return UISwipeActionsConfiguration(actions: [setFinal])
  }
}
