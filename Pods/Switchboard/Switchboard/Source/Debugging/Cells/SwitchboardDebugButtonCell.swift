//
//  SwitchboardDebugButtonCell.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/29/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugButtonCell: UITableViewCell {

    static let reuseIdentifier = "SwitchboardDebugButtonCell"

    // MARK: - Instantiation

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    // MARK: - API

    func configure(with setting: SwitchboardButtonSetting) {
        self.setting = setting
        button.setTitleColor(self.tintColor, for: .normal)
        button.setTitle(setting.title, for: .normal)
        button.isEnabled = setting.enabled
        button.alpha = setting.enabled ? 1 : 0.4
    }

    // MARK: - View Properties

    lazy var button: UIButton = { [unowned self] in
        let button = UIButton(type: .custom)
        button.setTitle(self.setting?.title, for: .normal)
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - Overrides

    override func prepareForReuse() {
        button.setTitle(nil, for: .normal)
        button.isEnabled = true
        button.alpha = 1
        setting = nil
    }

    // MARK: - Private Properties

    fileprivate weak var setting: SwitchboardButtonSetting?

    // MARK: - Unsupported Initializers

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugButtonCell {

    // MARK: - View Setup

    func setupView() {
        accessoryType = .none
        selectionStyle = .none

        button.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(button)
        NSLayoutConstraint.activate([button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                                     button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                                     button.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     contentView.heightAnchor.constraint(equalToConstant: 44)])
    }

    // MARK: - Actions

    @objc func buttonTapped() {
        setting?.tapHandler()
    }

}
#endif
