//
//  EmptyStateView.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR - Vendor on 6/30/25.
//


import UIKit

class EmptyStateView: UIView {
    private let stackView = UIStackView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    private var buttonAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        // Icon
        iconImageView.image = UIImage(systemName: "gamecontroller")
        iconImageView.tintColor = .systemGray3
        iconImageView.contentMode = .scaleAspectFit

        // Title
        titleLabel.font = .systemFont(ofSize: 24, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0

        // Subtitle
        subtitleLabel.font = .systemFont(ofSize: 16)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.textAlignment = .center
        subtitleLabel.numberOfLines = 0

        // Button
        actionButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        actionButton.layer.cornerRadius = 8

        // Stack
        stackView.axis = .vertical
        stackView.spacing = 12
        [iconImageView, titleLabel, subtitleLabel, actionButton].forEach {
            stackView.addArrangedSubview($0)
        }

        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    /// Call this to set the texts & button action
    func configure(
      title: String,
      subtitle: String,
      buttonTitle: String,
      action: @escaping () -> Void
    ) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.backgroundColor = .systemBlue
        actionButton.setTitleColor(.white, for: .normal)

        buttonAction = action
        actionButton.removeTarget(nil, action: nil, for: .allEvents)
        actionButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }

    @objc private func buttonTapped() {
        buttonAction?()
    }
}