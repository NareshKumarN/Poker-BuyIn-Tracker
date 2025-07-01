//
//  PlayerCardCell.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR 6/30/25.
//


import UIKit

protocol PlayerCardCellDelegate: AnyObject {
    func didSwipeLeft(on cell: PlayerCardCell, playerId: UUID)
    func didSwipeRight(on cell: PlayerCardCell, playerId: UUID)
}


class PlayerCardCell: UITableViewCell {
    weak var delegate: PlayerCardCellDelegate?
    private var playerId: UUID?

    private let cardView = UIView()
    private let nameLabel = UILabel()
    private let buyInLabel = UILabel()
    private let additionalBuyInsLabel = UILabel()
    private let statusLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupGestures()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none

        cardView.backgroundColor = .secondarySystemGroupedBackground
        cardView.layer.cornerRadius = 12
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 4
        cardView.layer.shadowOpacity = 0.1

        nameLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        buyInLabel.font = .systemFont(ofSize: 14)
        buyInLabel.textColor = .secondaryLabel
        additionalBuyInsLabel.font = .systemFont(ofSize: 14)
        additionalBuyInsLabel.textColor = .systemBlue
        statusLabel.font = .systemFont(ofSize: 12, weight: .medium)
        statusLabel.textAlignment = .right

        contentView.addSubview(cardView)
        [nameLabel, buyInLabel, additionalBuyInsLabel, statusLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            cardView.addSubview($0)
        }
        cardView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),

            nameLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            statusLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),

            buyInLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            buyInLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),

            additionalBuyInsLabel.topAnchor.constraint(equalTo: buyInLabel.bottomAnchor, constant: 4),
            additionalBuyInsLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            additionalBuyInsLabel.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16)
        ])
    }

    private func setupGestures() {
        let left = UISwipeGestureRecognizer(target: self, action: #selector(handleLeftSwipe))
        left.direction = .left
        cardView.addGestureRecognizer(left)

        let right = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe))
        right.direction = .right
        cardView.addGestureRecognizer(right)
    }

    @objc private func handleLeftSwipe() {
        guard let id = playerId else { return }
        delegate?.didSwipeLeft(on: self, playerId: id)
    }
    @objc private func handleRightSwipe() {
        guard let id = playerId else { return }
        delegate?.didSwipeRight(on: self, playerId: id)
    }

    func configure(with player: Player, session: Session) {
        self.playerId = player.id
        nameLabel.text = player.name

        // Compute buy-in totals
        let first = session.firstBuyIn
        let addCount = session.additionalBuyIns[player.id] ?? 0
        let addTotal = addCount * session.secondBuyIn
        buyInLabel.text = "First Buy‑in: $\(first)"
        additionalBuyInsLabel.text = "Additional: \(addCount) × $\(session.secondBuyIn) = $\(addTotal)"

        // Determine net profit if final chips set
        if let maybeChips = session.finalChips[player.id], let chips = maybeChips {
            let totalBuyIns = Double(first + addTotal)
            let net = chips - totalBuyIns
            statusLabel.text = String(format: "$%.2f", net)
            statusLabel.textColor = net < 0 ? .systemRed : .systemGreen
        } else {
            statusLabel.text = "Playing"
            statusLabel.textColor = .systemOrange
        }
    }
}
