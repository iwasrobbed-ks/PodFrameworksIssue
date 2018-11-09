//
//  SwitchboardPrefillExperimentView.swift
//  Switchboard
//
//  Created by Rob Phillips on 4/2/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
    import UIKit
    
    typealias SwitchboardPrefillExperimentSelected = (_ experiment: SwitchboardExperiment) -> ()
    
    internal class SwitchboardPrefillExperimentView: SwitchboardPrefillListView {
        
        /// Shows a list of experiments to prefill from
        ///
        /// - Parameters:
        ///   - existingExperiments: The existing experiments to compare against
        ///   - experimentSelected: A closure to call when an experiment is selected from the list
        init(existingExperiments: [SwitchboardExperiment], experimentSelected: @escaping SwitchboardPrefillExperimentSelected) {
            self.existingExperiments = existingExperiments
            self.experimentSelected = experimentSelected
            
            super.init()
            
            refreshExperimentsToShow()
        }
        
        // MARK: - Overrides
        
        override var debugTitle: String { return "Prefill Experiments" }
        
        // MARK: - UITableViewDataSource
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return experiments.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier, for: indexPath) as? SwitchboardDebugTapCell
                else { fatalError("Unsupported cell type ") }
            
            let experiment = experiments[indexPath.row]
            cell.configure(title: experiment.name, subtitle: "cohort: \(experiment.cohort)", accessoryType: .none)
            return cell
        }
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            guard editingStyle == .delete else { return }
            
            SwitchboardPrefillController.shared.delete(experiment: experiments[indexPath.row])
            refreshExperimentsToShow()
            if experiments.count == 0 {
                dismiss(animated: true, completion: nil)
            } else {
                tableView.reloadData()
            }
        }
        
        // MARK: - UITableViewDelegate
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            experimentSelected(experiments[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
        
        // MARK: - Private Properties
        
        fileprivate let existingExperiments: [SwitchboardExperiment]
        fileprivate let experimentSelected: SwitchboardPrefillExperimentSelected
        
        fileprivate var experiments = [SwitchboardExperiment]()
        
        fileprivate func refreshExperimentsToShow() {
            experiments = SwitchboardPrefillController.shared.experimentsUnique(from: existingExperiments)
        }
        
        // MARK: - Unsupported Initializers
        
        required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
#endif
