//
//  SwitchboardDebugTextViewCell.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugTextViewCell: UITableViewCell {

    static let reuseIdentifier = "SwitchboardDebugTextViewCell"

    // MARK: - Instantiation

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setupView()
    }

    // MARK: - API

    func configure(with setting: SwitchboardTextViewSetting) {
        self.setting = setting
        textView.text = setting.text
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        setting = nil
        textView.text = ""
    }

    // MARK: - View Properties

    let textView = UITextView()

    // MARK: - Private Properties

    fileprivate weak var setting: SwitchboardTextViewSetting?

    // MARK: - Unsupported Initializers

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}

// MARK: - UITextViewDelegate

extension SwitchboardDebugTextViewCell: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
        setting?.text = textView.text
    }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugTextViewCell {

    // MARK: - View Setup

    func setupView() {
        accessoryType = .none
        selectionStyle = .none

        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(textView)
        NSLayoutConstraint.activate([textView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 2),
                                     textView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -2),
                                     textView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 15),
                                     textView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                                     textView.heightAnchor.constraint(equalToConstant: 150)])
    }

}
#endif
