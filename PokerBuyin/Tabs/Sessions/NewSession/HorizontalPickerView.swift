//
//  HorizontalPickerView.swift
//  PokerBuyin
//
//  Created by NARESH KUMAR  6/30/25.
//


import UIKit

class HorizontalPickerView: UIView {
        private let scrollView = UIScrollView()
        private let stackView = UIStackView()
        private var valueButtons: [UIButton] = []
        private var selectedValue: Int = 0
        private var onValueChanged: ((Int) -> Void)?

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupUI()
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setupUI() {
            backgroundColor = .secondarySystemGroupedBackground
            layer.cornerRadius = 12

            addSubview(scrollView)
            scrollView.addSubview(stackView)

            scrollView.showsHorizontalScrollIndicator = false
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            stackView.translatesAutoresizingMaskIntoConstraints = false
            stackView.axis = .horizontal
            stackView.spacing = 16
            stackView.alignment = .center

            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

                stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
                stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
                stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor)
            ])
        }

        func configure(with values: [Int], selectedValue: Int, onValueChanged: @escaping (Int) -> Void) {
            self.selectedValue = selectedValue
            self.onValueChanged = onValueChanged

            stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
            valueButtons.removeAll()

            for value in values {
                let button = UIButton(type: .system)
                button.setTitle("$\(value)", for: .normal)
                button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
                button.layer.cornerRadius = 8
                button.backgroundColor = value == selectedValue ? .systemBlue : .clear
                button.setTitleColor(value == selectedValue ? .white : .label, for: .normal)
                button.tag = value
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)

                button.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    button.widthAnchor.constraint(equalToConstant: 50),
                    button.heightAnchor.constraint(equalToConstant: 40)
                ])

                stackView.addArrangedSubview(button)
                valueButtons.append(button)
            }

            // Scroll to selected value
            DispatchQueue.main.async {
                if let selectedButton = self.valueButtons.first(where: { $0.tag == selectedValue }) {
                    let buttonFrame = selectedButton.convert(selectedButton.bounds, to: self.scrollView)
                    let centerX = buttonFrame.midX - self.scrollView.bounds.width / 2
                    self.scrollView.setContentOffset(CGPoint(x: max(0, centerX), y: 0), animated: false)
                }
            }
        }

        @objc private func buttonTapped(_ sender: UIButton) {
            let newValue = sender.tag
            selectedValue = newValue
            onValueChanged?(newValue)

            // Update button appearances
            valueButtons.forEach { button in
                let isSelected = button.tag == newValue
                button.backgroundColor = isSelected ? .systemBlue : .clear
                button.setTitleColor(isSelected ? .white : .label, for: .normal)
            }

            // Scroll to center the selected button
            let buttonFrame = sender.convert(sender.bounds, to: scrollView)
            let centerX = buttonFrame.midX - scrollView.bounds.width / 2
            scrollView.setContentOffset(CGPoint(x: max(0, centerX), y: 0), animated: true)
        }
    }
