//
//  HighHandHeaderView.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//


import UIKit

class HighHandHeaderView: UIView {
    private let titleLabel = UILabel()
    private let typeLabel = UILabel()
    private let cardsLabel = UILabel()
    private let ownerLabel = UILabel()
    private let valueLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 120))
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 12
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.shadowOpacity = 0.1

        titleLabel.text = "High Hand"
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .systemRed

        typeLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        cardsLabel.font = .systemFont(ofSize: 14, weight: .medium)
        cardsLabel.textColor = .secondaryLabel
        ownerLabel.font = .systemFont(ofSize: 14)
        ownerLabel.textColor = .secondaryLabel
        valueLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        valueLabel.textColor = .systemGreen

        [titleLabel, typeLabel, cardsLabel, ownerLabel, valueLabel].forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            valueLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            typeLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            typeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            cardsLabel.topAnchor.constraint(equalTo: typeLabel.bottomAnchor, constant: 4),
            cardsLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),

            ownerLabel.topAnchor.constraint(equalTo: cardsLabel.bottomAnchor, constant: 4),
            ownerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            ownerLabel.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -16)
        ])
    }

    func configure(with session: Session) {
        typeLabel.text = session.highHandType
        cardsLabel.text = session.highHandCards ?? "Not set"
        valueLabel.text = "$\(Int(session.highHandValue))"

        if let ownerId = session.highHandOwner {
            let owner = DataStore.shared.users.first { $0.id == ownerId }
            ownerLabel.text = "Winner: \(owner?.name ?? "Unknown")"
        } else {
            ownerLabel.text = "Winner: Not determined"
        }
    }
}
