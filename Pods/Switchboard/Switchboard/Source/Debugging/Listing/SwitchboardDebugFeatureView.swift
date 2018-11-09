//
//  SwitchboardDebugFeatureView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/25/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

final internal class SwitchboardDebugFeatureView: SwitchboardDebugListView {

    // MARK: - Properties

    override var debugTitle: String { return "Features" }

    // MARK: - Overrides

    override func setupView() {
        super.setupView()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addFeatureTapped))
        tableView.tableHeaderView = header
        tableView.enableVariableHeightTableHeaderView()
    }

    // MARK: - UITableViewDataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let features = features(forSection: section) else { return 0 }
        return features.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier, for: indexPath) as? SwitchboardDebugTapCell
            else { fatalError("Unsupported cell type ") }

        guard let features = features(forSection: indexPath.section) else { return cell }
        let section = sections[indexPath.section]
        let feature = features[indexPath.row]
        cell.configure(title: section == .enabled ? "🔵 \(feature.name)" : "🔴 \(feature.name)")
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete, let features = features(forSection: indexPath.section) else { return }

        let feature = features[indexPath.row]
        debugController?.delete(feature: feature)
        SwitchboardPrefillController.shared.add(feature: feature)
        tableView.reloadData()

        debugController?.cacheAll()
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let features = features(forSection: indexPath.section), let debugController = debugController else { return }
        let feature = features[indexPath.row]
        let vc = SwitchboardDebugFeatureEditView(feature: feature, debugController: debugController) {
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

fileprivate extension SwitchboardDebugFeatureView {

    // MARK: - Actions

    @objc func addFeatureTapped() {
        var existingFeatures = [SwitchboardFeature]()
        existingFeatures.append(contentsOf: debugController?.activeFeatures ?? [])
        existingFeatures.append(contentsOf: debugController?.inactiveFeatures ?? [])
        if SwitchboardPrefillController.shared.canPrefillFeatures(for: existingFeatures) {
            showAddFeatureActionSheet(with: existingFeatures)
        } else {
            showAddFeatureDialog()
        }
    }
    
    func showAddFeatureActionSheet(with existingFeatures: [SwitchboardFeature]) {
        let actionSheet = UIAlertController(title: "How do you want to add a feature?", message: nil, preferredStyle: .actionSheet)
        let typeInNameAction = UIAlertAction(title: "Type in name", style: .default) { [weak self] _ in
            self?.showAddFeatureDialog()
        }
        let prefillAction = UIAlertAction(title: "Select from existing", style: .default) { [weak self] _ in
            let vc = SwitchboardPrefillFeatureView(existingFeatures: existingFeatures, featureSelected: { feature in
                self?.add(feature: feature)
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
    
    func showAddFeatureDialog() {
        let alertController = UIAlertController(title: "Add Feature", message: nil, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] alert in
            guard let strongSelf = self,
                  let textField = alertController?.textFields?.first,
                  let featureName = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
                  featureName.isEmpty == false,
                  let feature = SwitchboardFeature(name: featureName, analytics: strongSelf.debugController?.analytics)
                else { return }
            
            strongSelf.add(feature: feature)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addTextField { textField in
            textField.placeholder = "Feature name"
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func add(feature: SwitchboardFeature) {
        guard debugController?.exists(feature: feature) == false else { return }
        
        debugController?.activate(feature: feature)
        guard let featureIndex = debugController?.activeFeatures.index(of: feature),
              let sectionIndex = sections.index(of: .enabled) else {
                tableView.reloadData()
                return
        }
        tableView.beginUpdates()
        let indexPath = IndexPath(row: featureIndex, section: sectionIndex)
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        debugController?.cacheAll()
    }
    
    func enableAllTapped() {
        guard let sectionIndex = sections.index(of: .disabled),
              let features = features(forSection: sectionIndex)
            else { return }
        for feature in features {
            debugController?.activate(feature: feature)
        }
        debugController?.cacheAll()
        tableView.reloadData()
    }
    
    func disableAllTapped() {
        guard let sectionIndex = sections.index(of: .enabled),
              let features = features(forSection: sectionIndex)
            else { return }
        for feature in features {
            debugController?.deactivate(feature: feature)
        }
        debugController?.cacheAll()
        tableView.reloadData()
    }

    // MARK: - Helpers

    func features(forSection section: Int) -> [SwitchboardFeature]? {
        let section = sections[section]
        if section == .enabled { return debugController?.activeFeatures }
        if section == .disabled { return debugController?.inactiveFeatures }
        return nil
    }

}
#endif
