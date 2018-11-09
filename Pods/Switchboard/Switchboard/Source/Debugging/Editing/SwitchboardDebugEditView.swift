//
//  SwitchboardDebugEditView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

typealias SwitchboardDebugEditShouldRefresh = () -> ()

internal enum SwitchboardEditSection {
    case name, enabled, state, values, cohort

    var title: String {
        switch self {
        case .name: return "Name"
        case .enabled: return "Enabled"
        case .state: return "State"
        case .values: return "Values JSON String"
        case .cohort: return "Cohort"
        }
    }
}

internal class SwitchboardDebugEditView: UITableViewController {

    // MARK: - Instantiation

    init(feature: SwitchboardFeature? = nil, experiment: SwitchboardExperiment? = nil, debugController: SwitchboardDebugController, refreshHandler: @escaping SwitchboardDebugEditShouldRefresh) {
        self.feature = feature
        self.experiment = experiment
        self.debugController = debugController
        self.refreshHandler = refreshHandler

        if feature == nil && experiment == nil {
            fatalError("Must pass in either a non-nil feature or a non-nil experiment to edit it.")
        }

        super.init(style: .grouped)

        setupView()
    }

    // MARK: - Properties

    weak var feature: SwitchboardFeature?
    weak var experiment: SwitchboardExperiment?
    weak var debugController: SwitchboardDebugController?
    let refreshHandler: SwitchboardDebugEditShouldRefresh

    var editTitle: String {
        fatalError("override necessary")
    }

    var sections: [SwitchboardEditSection] {
        fatalError("override necessary")
    }

    var rows = [[SwitchboardDebugSetting]]()

    var itemName: String? {
        if let feature = feature { return feature.name }
        if let experiment = experiment { return experiment.name }
        return nil
    }

    var valuesString: String {
        let values: [String: Any]? = feature?.values ?? experiment?.values
        guard let string = string(from: values) else { return "{}" }
        return string
    }

    // MARK: - API

    func generateInitialRows() -> [[SwitchboardDebugSetting]] {
        fatalError("override necessary")
    }

    func formIsSaved() -> (saved: Bool, errorMessage: String?) {
        fatalError("override necessary")
    }

    func toggle(isOn: Bool) {
        if let feature = feature {
            debugController?.toggle(feature: feature)
        } else if let experiment = experiment {
            debugController?.toggle(experiment: experiment)
        }
    }

    func jsonDictionary(from string: String?) -> [String: Any]? {
        guard let stringValue = string,
              let stringData = stringValue.data(using: .utf8),
              let jsonDictionary = try? JSONSerialization.jsonObject(with: stringData, options: []) as? [String: Any]
            else { return nil }
        return jsonDictionary
    }

    func string(from dictionary: [String: Any]?) -> String? {
        guard let jsonValues = dictionary,
              let jsonData = try? JSONSerialization.data(withJSONObject: jsonValues, options: .prettyPrinted),
              let string = String(data: jsonData, encoding: .utf8) else {
                return nil
        }
        return string
    }

    // MARK: - UITableViewDataSource

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = rows[indexPath.section][indexPath.row]

        if let toggleRow = row as? SwitchboardToggleSetting, let cell = configure(toggleRow: toggleRow) {
            return cell
        } else if let textFieldRow = row as? SwitchboardTextFieldSetting, let cell = configure(textFieldRow: textFieldRow) {
            return cell
        } else if let textViewRow = row as? SwitchboardTextViewSetting, let cell = configure(textViewRow: textViewRow) {
            return cell
        } else if let buttonRow = row as? SwitchboardButtonSetting, let cell = configure(buttonRow: buttonRow) {
            return cell
        } else if let tapRow = row as? SwitchboardTappableSetting, let cell = configure(tappableRow: tapRow) {
            return cell
        }

        fatalError("Unhandled cell type")
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let row = rows[indexPath.section][indexPath.row]
        if let tapRow = row as? SwitchboardTappableSetting {
            return tapRow.tapHandler()
        }
    }

    // MARK: - Unsupported Initializers

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
}

// MARK: - Private API

fileprivate extension SwitchboardDebugEditView {

    // MARK: - View Setup

    func setupView() {
        title = editTitle

        // Must be done before the table is loaded
        rows = generateInitialRows()

        setupButtons()
        setupTable()
    }

    func setupButtons() {
        let cancelButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismissToCancel))
        navigationItem.leftBarButtonItem = cancelButtonItem

        let saveButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(dismissAfterSaving))
        navigationItem.rightBarButtonItem = saveButtonItem
    }

    func setupTable() {
        tableView.backgroundColor = SwitchboardColors.tableBackground
        tableView.estimatedRowHeight = 60
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.register(SwitchboardDebugToggleCell.self, forCellReuseIdentifier: SwitchboardDebugToggleCell.reuseIdentifier)
        tableView.register(SwitchboardDebugTextFieldCell.self, forCellReuseIdentifier: SwitchboardDebugTextFieldCell.reuseIdentifier)
        tableView.register(SwitchboardDebugTextViewCell.self, forCellReuseIdentifier: SwitchboardDebugTextViewCell.reuseIdentifier)
        tableView.register(SwitchboardDebugButtonCell.self, forCellReuseIdentifier: SwitchboardDebugButtonCell.reuseIdentifier)
        tableView.register(SwitchboardDebugTapCell.self, forCellReuseIdentifier: SwitchboardDebugTapCell.reuseIdentifier)
    }

    // MARK: - Actions

    @objc func dismissToCancel() {
        dismiss(animated: true, completion: nil)
    }

    @objc func dismissAfterSaving() {
        let (saved, errorMessage) = formIsSaved()
        guard saved else {
            let message = errorMessage ?? "Unknown error."
            let alertController = UIAlertController(title: "Invalid form", message: "There was an issue with the form: \(message)", preferredStyle: .alert)
            let dontSaveAction = UIAlertAction(title: "Don't save", style: .destructive) { alert in
                self.refreshHandler()
                self.dismiss(animated: true, completion: nil)
            }
            let fixAction = UIAlertAction(title: "Fix it", style: .default)
            alertController.addAction(dontSaveAction)
            alertController.addAction(fixAction)
            navigationController?.present(alertController, animated: true, completion: nil)
            return
        }

        debugController?.cacheAll()
        refreshHandler()
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Configuration

    func configure(toggleRow: SwitchboardToggleSetting) -> SwitchboardDebugToggleCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugToggleCell.reuseIdentifier) as? SwitchboardDebugToggleCell else { return nil }
        var isOn = false
        if let feature = feature {
            isOn = debugController?.activeFeatures.contains(feature) == true
        } else if let experiment = experiment {
            isOn = debugController?.activeExperiments.contains(experiment) == true
        }
        cell.configure(with: toggleRow, isOn: isOn)
        return cell
    }

    func configure(textFieldRow: SwitchboardTextFieldSetting) -> SwitchboardDebugTextFieldCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTextFieldCell.reuseIdentifier) as? SwitchboardDebugTextFieldCell else { return nil }
        cell.configure(with: textFieldRow)
        return cell
    }

    func configure(textViewRow: SwitchboardTextViewSetting) -> SwitchboardDebugTextViewCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTextViewCell.reuseIdentifier) as? SwitchboardDebugTextViewCell else { return nil }
        cell.configure(with: textViewRow)
        return cell
    }

    func configure(buttonRow: SwitchboardButtonSetting) -> SwitchboardDebugButtonCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugButtonCell.reuseIdentifier) as? SwitchboardDebugButtonCell else { return nil }
        cell.configure(with: buttonRow)
        return cell
    }

    func configure(tappableRow: SwitchboardTappableSetting) -> SwitchboardDebugTapCell? {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier) as? SwitchboardDebugTapCell else { return nil }
        cell.configure(with: tappableRow)
        return cell
    }

}
#endif

