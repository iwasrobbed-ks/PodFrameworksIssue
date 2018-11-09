//
//  SwitchboardDebugListView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/26/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

internal enum SwitchboardDebugListSection {
    case enabled, disabled

    var title: String {
        switch self {
        case .enabled: return "Enabled"
        case .disabled: return "Disabled"
        }
    }
}

internal class SwitchboardDebugListView: UITableViewController {

    // MARK: - Instantiation

    init(debugController: SwitchboardDebugController) {
        self.debugController = debugController

        super.init(style: .grouped)

        setupView()
        SwitchboardPrefillController.shared.populateExperimentsIfNeeded(in: debugController.switchboard,
                                                                        analytics: debugController.analytics)
    }

    // MARK: - Properties

    var debugTitle: String { return "" }
    let sections: [SwitchboardDebugListSection] = [.enabled, .disabled]
    weak var debugController: SwitchboardDebugController?

    // MARK: - API

    func setupView() {
        title = debugTitle
        navigationItem.backBarButtonItem?.title = ""

        tableView.backgroundColor = SwitchboardColors.tableBackground
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(SwitchboardDebugTapCell.self, forCellReuseIdentifier: SwitchboardDebugTapCell.reuseIdentifier)
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("override necessary")
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("override necessary")
    }

    // MARK: - Unsupported Initializers

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

}
#endif
