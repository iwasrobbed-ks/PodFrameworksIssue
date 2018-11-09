//
//  SwitchboardDebugToggleCell.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugToggleCell: UITableViewCell {

    static let reuseIdentifier = "SwitchboardDebugToggleCell"

    // MARK: - Instantiation

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    // MARK: - API

    func configure(with setting: SwitchboardToggleSetting, isOn: Bool) {
        textLabel?.text = setting.title
        toggle.isOn = setting.toggledOn ?? isOn
        self.setting = setting
    }

    // MARK: - View Properties

    lazy var toggle: UISwitch = { [unowned self] in
        let toggle = UISwitch()
        toggle.accessibilityLabel = "Enabled Toggle"
        toggle.addTarget(self, action: #selector(toggleSwitch), for: .valueChanged)
        return toggle
    }()

    // MARK: - Overrides

    override func prepareForReuse() {
        textLabel?.text = ""
        setting = nil
        toggle.isOn = false
    }

    // MARK: - Private Properties

    fileprivate weak var setting: SwitchboardToggleSetting?

    // MARK: - Unsupported Initializers

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugToggleCell {

    // MARK: - View Setup

    func setupView() {
        textLabel?.font = .systemFont(ofSize: 18)
        accessoryType = .none
        selectionStyle = .none

        toggle.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(toggle)
        NSLayoutConstraint.activate([toggle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
                                     toggle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     contentView.heightAnchor.constraint(equalToConstant: 44)])
    }

    // MARK: - Actions

    @objc func toggleSwitch() {
        setting?.toggledOn = toggle.isOn
        setting?.toggleHandler(toggle.isOn)
    }

}
#endif
