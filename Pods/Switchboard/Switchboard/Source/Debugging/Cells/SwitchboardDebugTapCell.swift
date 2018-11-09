//
//  SwitchboardDebugTapCell.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugTapCell: UITableViewCell {

    static let reuseIdentifier = "SwitchboardDebugTapCell"

    // MARK: - Instantiation

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        textLabel?.font = .systemFont(ofSize: 18)
        accessoryType = .disclosureIndicator
    }

    // MARK: - API

    func configure(with setting: SwitchboardTappableSetting) {
        configure(title: setting.title, subtitle: nil, accessoryType: setting.selected ? .checkmark : .none)
    }

    func configure(title: String, subtitle: String? = nil, accessoryType: UITableViewCell.AccessoryType = .disclosureIndicator) {
        textLabel?.text = title
        detailTextLabel?.text = subtitle
        self.accessoryType = accessoryType
    }

    // MARK: - Overrides

    override func prepareForReuse() {
        textLabel?.text = ""
        detailTextLabel?.text = ""
        accessoryType = .disclosureIndicator
    }

    // MARK: - Unsupported Initializers

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}
#endif
