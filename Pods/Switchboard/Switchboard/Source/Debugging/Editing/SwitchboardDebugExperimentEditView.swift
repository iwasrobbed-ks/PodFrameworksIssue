//
//  SwitchboardDebugExperimentEditView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/// Note: this class is transactional, so all changes are temporary until the Save button is pressed
final internal class SwitchboardDebugExperimentEditView: SwitchboardDebugEditView {

    // MARK: - Instantiation

    required init(experiment: SwitchboardExperiment, debugController: SwitchboardDebugController, refreshHandler: @escaping SwitchboardDebugEditShouldRefresh) {
        super.init(feature: nil, experiment: experiment, debugController: debugController, refreshHandler: refreshHandler)

        setupInitiallyAvailableCohorts()
        setupInitialExperimentState()
    }

    // MARK: - Overrides

    override var editTitle: String { return "Edit Experiment" }

    override var sections: [SwitchboardEditSection] {
        return [.name,
                .enabled,
                .state,
                .cohort,
                .values]
    }

    override func generateInitialRows() -> [[SwitchboardDebugSetting]] {
        // Note: the array of arrays correlates with the section this item is in
        // so the first array is the "Name" section, etc
        return [[name],
                [enabled],
                [state, startExperiment, completeExperiment, resetExperiment],
                [addCohort],
                [values]]
    }

    override func formIsSaved() -> (saved: Bool, errorMessage: String?) {
        guard let newValues = valuesDictionary else {
            return (false, "Could not parse values string into a JSON dictionary. Make sure it's valid JSON.")
        }
        guard newValues[SwitchboardKeys.cohort] != nil else {
            return (false, "Experiments must have a cohort assigned in their values JSON dictionary in order to be considered an 'experiment'.")
        }
        guard let experiment = experiment else {
            return (false, "No experiment available to save to.")
        }

        debugController?.update(availableCohorts: availableCohortSettings.map({ $0.title }), for: experiment)
        debugController?.change(values: newValues, for: experiment)
        if let newToggleValue = newToggleValue {
            toggle(isOn: newToggleValue)
        }
        if let newState = newExperimentState {
            if newState == .started {
                experiment.start()
            } else if newState == .completed {
                experiment.complete()
            } else if newState == .reset {
                experiment.clearState()
            }
        }
        return (true, nil)
    }

    // MARK: - Cohort Removal

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Allow cohorts to be deleted (as long as it's not the Add Cohort button or the only cohort)
        return isCohort(at: indexPath) && availableCohortSettings.count != 1
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, isCohort(at: indexPath) else { return }

        let index = indexPath.row - (addCohortButtonIndex + 1) // offset for add cohort button
        let cohortToDelete = availableCohortSettings[index]
        remove(cohort: cohortToDelete)

        // If we deleted the selected cohort, select the top one
        if cohortToDelete.selected, let topCohort = availableCohortSettings.first {
            selectCohort(named: topCohort.title)
        }

        tableView.reloadData()
    }

    // MARK: - Private Properties

    fileprivate lazy var name: SwitchboardTextFieldSetting = { [unowned self] in
        return SwitchboardTextFieldSetting(placeholder: "Experiment Name", text: self.itemName, editable: false)
    }()

    fileprivate lazy var enabled: SwitchboardToggleSetting = { [unowned self] in
        return SwitchboardToggleSetting(title: "Enabled", toggleHandler: { isOn in
            self.newToggleValue = isOn
        })
    }()

    fileprivate lazy var addCohort: SwitchboardButtonSetting = { [unowned self] in
        return SwitchboardButtonSetting(title: "Add cohort", tapHandler: {
            self.showAddCohortDialog()
        })
    }()

    fileprivate lazy var state: SwitchboardTextFieldSetting = { [unowned self] in
        return SwitchboardTextFieldSetting(placeholder: "State", text: self.experimentStateString, editable: false)
    }()

    fileprivate lazy var startExperiment: SwitchboardButtonSetting = { [unowned self] in
        return SwitchboardButtonSetting(title: "Start experiment", tapHandler: {
            self.startExperimentTapped()
        })
    }()

    fileprivate lazy var completeExperiment: SwitchboardButtonSetting = { [unowned self] in
        return SwitchboardButtonSetting(title: "Complete experiment", tapHandler: {
            self.completeExperimentTapped()
        })
    }()

    fileprivate lazy var resetExperiment: SwitchboardButtonSetting = { [unowned self] in
        return SwitchboardButtonSetting(title: "Reset experiment", tapHandler: {
            self.resetExperimentTapped()
        })
    }()

    fileprivate lazy var values: SwitchboardTextViewSetting = { [unowned self] in
        return SwitchboardTextViewSetting(text: self.valuesString)
    }()

    fileprivate var valuesDictionary: [String: Any]? {
        return jsonDictionary(from: values.text)
    }

    fileprivate var newToggleValue: Bool?

    fileprivate var availableCohortSettings = [SwitchboardTappableSetting]()
    fileprivate let addCohortButtonIndex: Int = 0

    fileprivate enum ExperimentState {
        case unknown, entitledToStart, started, completed, reset

        var title: String {
            switch self {
            case .unknown: return "Unknown"
            case .entitledToStart, .reset: return "Entitled to start"
            case .started: return "Started"
            case .completed: return "Completed"
            }
        }
    }

    fileprivate var experimentState: ExperimentState = .unknown
    fileprivate var newExperimentState: ExperimentState?

    fileprivate var experimentStateString: String {
        return newExperimentState?.title ?? experimentState.title
    }

    // MARK: - Unsupported Initializers

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(feature: SwitchboardFeature?, experiment: SwitchboardExperiment?, debugController: SwitchboardDebugController, refreshHandler: @escaping SwitchboardDebugEditShouldRefresh) { fatalError("use init(experiment:debugController:refreshHandler:) instead") }

}

// MARK: - Private API

fileprivate extension SwitchboardDebugExperimentEditView {

    // MARK: - State

    func setupInitialExperimentState() {
        guard let experiment = experiment else { return }
        if experiment.isEntitled {
            experimentState = .entitledToStart
        } else if experiment.isActive {
            experimentState = .started
        } else if experiment.isCompleted {
            experimentState = .completed
        }

        updateState(new: false, text: experimentState.title)
        enableButtonsIfNecessary(state: experimentState)
    }

    func startExperimentTapped() {
        newExperimentState = .started
        updateState(text: newExperimentState?.title)
        enableButtonsIfNecessary(state: .started)
    }

    func completeExperimentTapped() {
        newExperimentState = .completed
        updateState(text: newExperimentState?.title)
        enableButtonsIfNecessary(state: .completed)
    }

    func resetExperimentTapped() {
        newExperimentState = .reset
        updateState(text: newExperimentState?.title)
        enableButtonsIfNecessary(state: .entitledToStart)
    }

    func updateState(new: Bool = true, text: String?) {
        let currentOrNew = new ? "New" : "Current"
        let stateText = text ?? "Unknown"
        state.text = "\(currentOrNew) State: \(stateText)"
    }

    func enableButtonsIfNecessary(state newState: ExperimentState) {
        startExperiment.enabled = newState == .entitledToStart
        completeExperiment.enabled = newState == .started
        tableView.reloadData()
    }

    // MARK: - Cohorts

    func isCohort(at indexPath: IndexPath) -> Bool {
        guard let cohortSection = sections.index(of: .cohort), indexPath.section == cohortSection, indexPath.row != addCohortButtonIndex else {
            return false
        }
        return true
    }

    func setupInitiallyAvailableCohorts() {
        // Setup any pre-populated values based on this experiment's name
        for (experimentName, cohorts) in SwitchboardExperiment.namesMappedToCohorts where experiment?.name == experimentName {
            cohorts.forEach({ createTappableCohort(named: $0) })
        }
        // Also restore any cached values
        experiment?.availableCohorts.forEach({ createTappableCohort(named: $0) })

        if let currentCohort = experiment?.cohort {
            // This is redundant just in case the available cohorts contains the current cohort
            // we go ahead and select it a second time in case the guard below returns early
            createTappableCohort(named: currentCohort)
            self.selectCohort(named: currentCohort)
        }
    }

    func createTappableCohort(named name: String, selected: Bool = true) {
        let newCohort = SwitchboardTappableSetting(title: name, selected: selected) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.selectCohort(named: name)
        }
        add(cohort: newCohort)
        selectCohort(named: name)
    }

    func add(cohort: SwitchboardTappableSetting) {
        guard availableCohortSettings.contains(cohort) == false,
              let cohortSection = sections.index(of: .cohort)
            else { return }

        // Keep the array orders in sync
        availableCohortSettings.append(cohort)
        var newRows: [SwitchboardTappableSetting] = [addCohort]
        newRows.append(contentsOf: availableCohortSettings)
        rows[cohortSection] = newRows
    }

    func remove(cohort: SwitchboardTappableSetting) {
        guard let cohortSection = sections.index(of: .cohort),
              let availableIndex = availableCohortSettings.index(of: cohort)
            else { return }

        // Keep the array orders in sync
        availableCohortSettings.remove(at: availableIndex)
        var newRows: [SwitchboardTappableSetting] = [addCohort]
        newRows.append(contentsOf: availableCohortSettings)
        rows[cohortSection] = newRows
    }

    func selectCohort(named name: String) {
        // Update cohort section
        availableCohortSettings.forEach({ $0.selected = false })
        availableCohortSettings.filter({ $0.title == name }).first?.selected = true

        // Update values dictionary to match
        updateValuesWith(cohort: name)

        // Refresh table
        tableView.reloadData()
    }

    func updateValuesWith(cohort: String) {
        // Turn it into a dictionary and set it
        guard var dictionary = jsonDictionary(from: values.text) else { return }
        dictionary[SwitchboardKeys.cohort] = cohort

        // Turn it back into a string and display it
        guard let string = string(from: dictionary) else { return }
        values.text = string
    }

    func exists(cohort: String) -> Bool {
        return availableCohortSettings.filter({ $0.title == cohort }).first != nil
    }

    func showAddCohortDialog() {
        let alertController = UIAlertController(title: "Add Cohort", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] alert in
            guard let strongSelf = self,
                  let textField = alertController?.textFields?.first,
                  let cohortName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  cohortName.isEmpty == false,
                  strongSelf.exists(cohort: cohortName) == false
                else { return }

            let escapedName = cohortName.replacingOccurrences(of: "\"", with: "")
            strongSelf.createTappableCohort(named: escapedName)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { textField in
            textField.placeholder = "Cohort name"
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        navigationController?.present(alertController, animated: true, completion: nil)
    }

}
#endif
