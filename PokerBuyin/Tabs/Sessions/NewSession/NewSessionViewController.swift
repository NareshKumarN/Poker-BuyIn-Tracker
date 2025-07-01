//
//  NewSessionViewController.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR - Vendor on 6/30/25.
//


import UIKit
import UIKit

class NewSessionViewController: UIViewController {
        private let scrollView = UIScrollView()
        private let contentView = UIView()
        private let store = DataStore.shared

        private let firstBuyInScrollView = HorizontalPickerView()
        private let secondBuyInScrollView = HorizontalPickerView()
        private let selectPlayersButton = UIButton(type: .system)
        private let selectedPlayersLabel = UILabel()

        private var firstBuyInValue = 15
        private var secondBuyInValue = 10
        private var selectedPlayers: Set<UUID> = []
        private let buyInValues = Array(1...20)

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
            setupConstraints()
        }

        private func setupUI() {
            view.backgroundColor = .systemBackground
            title = "New Session"

            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Start", style: .done, target: self, action: #selector(startSession))

            // Setup scroll view
            view.addSubview(scrollView)
            scrollView.addSubview(contentView)

            // First Buy-in
            let firstLabel = UILabel()
            firstLabel.text = "First Buy-in"
            firstLabel.font = .systemFont(ofSize: 18, weight: .semibold)

            firstBuyInScrollView.configure(with: buyInValues, selectedValue: firstBuyInValue) { [weak self] value in
                self?.firstBuyInValue = value
            }

            // Second Buy-in
            let secondLabel = UILabel()
            secondLabel.text = "Additional Buy-in"
            secondLabel.font = .systemFont(ofSize: 18, weight: .semibold)

            secondBuyInScrollView.configure(with: buyInValues, selectedValue: secondBuyInValue) { [weak self] value in
                self?.secondBuyInValue = value
            }

            // Players Selection
            let playersLabel = UILabel()
            playersLabel.text = "Players"
            playersLabel.font = .systemFont(ofSize: 18, weight: .semibold)

            selectPlayersButton.setTitle("Select Players", for: .normal)
            selectPlayersButton.titleLabel?.font = .systemFont(ofSize: 16)
            selectPlayersButton.backgroundColor = .systemBlue
            selectPlayersButton.setTitleColor(.white, for: .normal)
            selectPlayersButton.layer.cornerRadius = 12
            selectPlayersButton.addTarget(self, action: #selector(selectPlayers), for: .touchUpInside)

            selectedPlayersLabel.text = "No players selected"
            selectedPlayersLabel.font = .systemFont(ofSize: 14)
            selectedPlayersLabel.textColor = .secondaryLabel
            selectedPlayersLabel.numberOfLines = 0

            [firstLabel, firstBuyInScrollView, secondLabel, secondBuyInScrollView, playersLabel, selectPlayersButton, selectedPlayersLabel].forEach {
                contentView.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            }
        }

        private func setupConstraints() {
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            contentView.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

                contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
                contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            ])

            let stackView = UIStackView(arrangedSubviews: [
                contentView.subviews[0], contentView.subviews[1],
                contentView.subviews[2], contentView.subviews[3],
                contentView.subviews[4], contentView.subviews[5], contentView.subviews[6]
            ])
            stackView.axis = .vertical
            stackView.spacing = 20
            stackView.translatesAutoresizingMaskIntoConstraints = false

            contentView.addSubview(stackView)
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 30),
                stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30),

                firstBuyInScrollView.heightAnchor.constraint(equalToConstant: 60),
                secondBuyInScrollView.heightAnchor.constraint(equalToConstant: 60),
                selectPlayersButton.heightAnchor.constraint(equalToConstant: 50)
            ])
        }

        @objc private func cancel() {
            dismiss(animated: true)
        }

        @objc private func selectPlayers() {
            let vc = PlayerSelectionViewController(selectedPlayers: selectedPlayers) { [weak self] players in
                self?.selectedPlayers = players
                self?.updateSelectedPlayersLabel()
            }
            navigationController?.pushViewController(vc, animated: true)
        }

        private func updateSelectedPlayersLabel() {
            if selectedPlayers.isEmpty {
                selectedPlayersLabel.text = "No players selected"
            } else {
                let names = selectedPlayers.compactMap { id in
                    store.users.first { $0.id == id }?.name
                }
                selectedPlayersLabel.text = "\(names.count) players: \(names.joined(separator: ", "))"
            }
        }

        @objc private func startSession() {
            guard !selectedPlayers.isEmpty else {
                let alert = UIAlertController(title: "Error", message: "Please select at least one player", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                present(alert, animated: true)
                return
            }

            store.addSession(firstBuyIn: firstBuyInValue, secondBuyIn: secondBuyInValue, playerIds: Array(selectedPlayers))
            dismiss(animated: true)
        }
    }
