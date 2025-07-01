//
//  CurrentSessionViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR - Vendor on 6/30/25.
//

import UIKit
import Combine

class CurrentSessionViewController: UIViewController {
  private let store = DataStore.shared
  private let emptyStateView = EmptyStateView()
  private var sessionDetailVC: SessionDetailViewController?
  private var currentSession: Session?

  private var cancellables = Set<AnyCancellable>()

  private lazy var endSessionButton = UIBarButtonItem(
    title: "End Session",
    style: .plain,
    target: self,
    action: #selector(endSessionTapped)
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()

    store.$sessions
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        self?.updateCurrentSession()
      }
      .store(in: &cancellables)
  }

  private func setupUI() {
    view.backgroundColor = .systemGroupedBackground
    title = "Current Session"
    navigationItem.rightBarButtonItem = nil

    emptyStateView.configure(
      title: "No Active Session",
      subtitle: "Start a new poker session to track buy‑ins and manage your game",
      buttonTitle: "Start New Session"
    ) { [weak self] in self?.startNewSession() }

    view.addSubview(emptyStateView)
    emptyStateView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
      emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
      emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
    ])
  }

  private func updateCurrentSession() {
    if let active = store.sessions
      .filter({ !$0.isEnded })
      .sorted(by: { $0.date > $1.date })
      .first
    {
      currentSession = active
      showSessionDetail(active)
      navigationItem.rightBarButtonItem = endSessionButton
    } else {
      currentSession = nil
      showEmptyState()
      navigationItem.rightBarButtonItem = nil
    }
  }

  @objc private func startNewSession() {
    let vc = NewSessionViewController()
    present(UINavigationController(rootViewController: vc), animated: true)
  }

  @objc private func endSessionTapped() {
    guard let session = currentSession else { return }
    let alert = UIAlertController(
      title: "End Session?",
      message: "Are you sure you want to end this session? You won’t be able to track buy‑ins anymore.",
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
    alert.addAction(UIAlertAction(title: "End", style: .destructive) { _ in
      DataStore.shared.endSession(id: session.id)
    })
    present(alert, animated: true)
  }

  private func showSessionDetail(_ session: Session) {
    emptyStateView.isHidden = true

    if let detail = sessionDetailVC {
      if detail.session.id == session.id {
        // Same session: just update in place (this will refresh high‑hand header + table)
        detail.update(with: session)
        return
      }
      // Different session: tear down old child
      detail.willMove(toParent: nil)
      detail.view.removeFromSuperview()
      detail.removeFromParent()
    }

    // Create new detail VC *as editable*, so it shows your High‑Hand prize and edit controls
    let detail = SessionDetailViewController(session: session, isEditable: true)
    addChild(detail)
    view.addSubview(detail.view)
    detail.view.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      detail.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      detail.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      detail.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      detail.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
    detail.didMove(toParent: self)
    sessionDetailVC = detail
  }

  private func showEmptyState() {
    emptyStateView.isHidden = false
    sessionDetailVC?.willMove(toParent: nil)
    sessionDetailVC?.view.removeFromSuperview()
    sessionDetailVC?.removeFromParent()
    sessionDetailVC = nil
  }
}
