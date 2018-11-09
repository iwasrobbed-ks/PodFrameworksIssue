//
//  SwitchboardDebugTextFieldCell.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugTextFieldCell: UITableViewCell {

    static let reuseIdentifier = "SwitchboardDebugTextFieldCell"

    // MARK: - Instantiation

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    // MARK: - API

    func configure(with setting: SwitchboardTextFieldSetting) {
        self.setting = setting
        textField.text = setting.text
        textField.placeholder = setting.placeholder
        textField.isEnabled = setting.editable
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        setting = nil
        textField.text = ""
        textField.placeholder = ""
        textField.isEnabled = true
    }

    // MARK: - View Properties

    let textField = UITextField()

    // MARK: - Private Properties

    fileprivate weak var setting: SwitchboardTextFieldSetting?

    // MARK: - Unsupported Initializers

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugTextFieldCell {

    // MARK: - View Setup

    func setupView() {
        accessoryType = .none
        selectionStyle = .none

        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                                     textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
                                     textField.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                                     contentView.heightAnchor.constraint(equalToConstant: 44)])
    }

    // MARK: - Editing

    @objc func textFieldDidChange() {
        setting?.text = textField.text
    }

}
#endif
