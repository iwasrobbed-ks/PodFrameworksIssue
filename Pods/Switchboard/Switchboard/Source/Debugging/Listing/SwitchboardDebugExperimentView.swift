//
//  SwitchboardDebugExperimentView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/25/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugExperimentView: SwitchboardDebugListView {

    // MARK: - Properties

    override var debugTitle: String { return "Experiments" }

    // MARK: - Overrides

    override func setupView() {
        super.setupView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addExperimentTapped))
        tableView.tableHeaderView = header
        tableView.enableVariableHeightTableHeaderView()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let experiments = experiments(forSection: section) else { return 0 }
        return experiments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier, for: indexPath) as? SwitchboardDebugTapCell
            else { fatalError("Unsupported cell type ") }

        guard let experiments = experiments(forSection: indexPath.section) else { return cell }
        let section = sections[indexPath.section]
        let experiment = experiments[indexPath.row]
        let subtitle = "status: \(statusFor(experiment: experiment)) ∙ cohort: \(experiment.cohort)"
        cell.configure(title: section == .enabled ? "🔵 \(experiment.name)" : "🔴 \(experiment.name)", subtitle: subtitle)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, let experiments = experiments(forSection: indexPath.section) else { return }

        let experiment = experiments[indexPath.row]
        debugController?.delete(experiment: experiment)
        SwitchboardPrefillController.shared.add(experiment: experiment)
        tableView.reloadData()

        debugController?.cacheAll()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let experiments = experiments(forSection: indexPath.section), let debugController = debugController else { return }
        let experiment = experiments[indexPath.row]
        let vc = SwitchboardDebugExperimentEditView(experiment: experiment, debugController: debugController) {
            self.tableView.reloadData()
        }
        let navVC = UINavigationController(rootViewController: vc)
        navigationController?.present(navVC, animated: true, completion: nil)
    }
    
    // MARK: - Private Properties
    
    fileprivate lazy var header: SwitchboardDebugListHeader = { [unowned self] in
        let view = SwitchboardDebugListHeader(enableAllTapped: {
            self.enableAllTapped()
        }, disableAllTappped: {
            self.disableAllTapped()
        })
        return view
    }()

}

// MARK: - Private API

fileprivate extension SwitchboardDebugExperimentView {

    // MARK: - Actions
    
    @objc func addExperimentTapped() {
        var existingExperiments = [SwitchboardExperiment]()
        existingExperiments.append(contentsOf: debugController?.activeExperiments ?? [])
        existingExperiments.append(contentsOf: debugController?.inactiveExperiments ?? [])
        if SwitchboardPrefillController.shared.canPrefillExperiments(for: existingExperiments) {
            showAddExperimentActionSheet(with: existingExperiments)
        } else {
            showAddExperimentDialog()
        }
    }
    
    func showAddExperimentActionSheet(with existingExperiments: [SwitchboardExperiment]) {
        let actionSheet = UIAlertController(title: "How do you want to add an experiment?", message: nil, preferredStyle: .actionSheet)
        let typeInNameAction = UIAlertAction(title: "Type in name and cohort", style: .default) { [weak self] _ in
            self?.showAddExperimentDialog()
        }
        let prefillAction = UIAlertAction(title: "Select from existing", style: .default) { [weak self] _ in
            let vc = SwitchboardPrefillExperimentView(existingExperiments: existingExperiments, experimentSelected: { experiment in
                self?.add(experiment: experiment)
            })
            let navVC = UINavigationController(rootViewController: vc)
            self?.present(navVC, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        actionSheet.addAction(typeInNameAction)
        actionSheet.addAction(prefillAction)
        actionSheet.addAction(cancelAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    func add(experiment: SwitchboardExperiment) {
        guard debugController?.exists(experiment: experiment) == false else { return }
        
        debugController?.activate(experiment: experiment)
        guard let experimentIndex = debugController?.activeExperiments.index(of: experiment),
              let sectionIndex = sections.index(of: .enabled) else {
                tableView.reloadData()
                return
        }
        tableView.beginUpdates()
        let indexPath = IndexPath(row: experimentIndex, section: sectionIndex)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        debugController?.cacheAll()
    }

    func showAddExperimentDialog() {
        let alertController = UIAlertController(title: "Add Experiment", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] alert in
            guard let strongSelf = self,
                  let nameTextField = alertController?.textFields?.first,
                  let cohortTextField = alertController?.textFields?.last,
                  let experimentName = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  let cohortName = cohortTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  experimentName.isEmpty == false,
                  cohortName.isEmpty == false,
                  let switchboard = strongSelf.debugController?.switchboard,
                  let experiment = SwitchboardExperiment(name: experimentName, cohort: cohortName,
                                                         switchboard: switchboard, analytics: strongSelf.debugController?.analytics)
                else { return }

            strongSelf.add(experiment: experiment)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { textField in
            textField.placeholder = "Experiment name"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Cohort name"
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func enableAllTapped() {
        guard let sectionIndex = sections.index(of: .disabled),
            let experiments = experiments(forSection: sectionIndex)
            else { return }
        for experiment in experiments {
            debugController?.activate(experiment: experiment)
        }
        debugController?.cacheAll()
        tableView.reloadData()
    }
    
    func disableAllTapped() {
        guard let sectionIndex = sections.index(of: .enabled),
            let experiments = experiments(forSection: sectionIndex)
            else { return }
        for experiment in experiments {
            debugController?.deactivate(experiment: experiment)
        }
        debugController?.cacheAll()
        tableView.reloadData()
    }

    // MARK: - Helpers

    func experiments(forSection section: Int) -> [SwitchboardExperiment]? {
        let section = sections[section]
        if section == .enabled { return debugController?.activeExperiments }
        if section == .disabled { return debugController?.inactiveExperiments }
        return nil
    }

    func statusFor(experiment: SwitchboardExperiment) -> String {
        if experiment.isEntitled {
            return "entitled to start"
        }
        if experiment.isActive {
            return "started"
        }
        if experiment.isCompleted {
            return "completed"
        }
        return "unknown"
    }

}
#endif
