//
//  SwitchboardPrefillFeatureView.swift
//  Switchboard
//
//  Created by Rob Phillips on 4/2/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
    import UIKit

    typealias SwitchboardPrefillFeatureSelected = (_ feature: SwitchboardFeature) -> ()
    
    internal class SwitchboardPrefillFeatureView: SwitchboardPrefillListView {
        
        /// Shows a list of features to prefill from
        ///
        /// - Parameters:
        ///   - existingFeatures: The existing features to compare against
        ///   - featureSelected: A closure to call when a feature is selected from the list
        init(existingFeatures: [SwitchboardFeature], featureSelected: @escaping SwitchboardPrefillFeatureSelected) {
            self.existingFeatures = existingFeatures
            self.featureSelected = featureSelected
            
            super.init()
            
            refreshFeaturesToShow()
        }
        
        // MARK: - Overrides
        
        override var debugTitle: String { return "Prefill Features" }
        
        // MARK: - UITableViewDataSource
        
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return features.count
        }
        
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SwitchboardDebugTapCell.reuseIdentifier, for: indexPath) as? SwitchboardDebugTapCell
                else { fatalError("Unsupported cell type ") }
            
            cell.configure(title: "\(features[indexPath.row].name)", accessoryType: .none)
            return cell
        }
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            guard editingStyle == .delete else { return }
            
            SwitchboardPrefillController.shared.delete(feature: features[indexPath.row])
            refreshFeaturesToShow()
            if features.count == 0 {
                dismiss(animated: true, completion: nil)
            } else {
                tableView.reloadData()
            }
        }
        
        // MARK: - UITableViewDelegate
        
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            featureSelected(features[indexPath.row])
            dismiss(animated: true, completion: nil)
        }
        
        // MARK: - Private Properties
        
        fileprivate let existingFeatures: [SwitchboardFeature]
        fileprivate let featureSelected: SwitchboardPrefillFeatureSelected
        
        fileprivate var features = [SwitchboardFeature]()
        
        fileprivate func refreshFeaturesToShow() {
            features = SwitchboardPrefillController.shared.featuresUnique(from: existingFeatures)
        }
        
        // MARK: - Unsupported Initializers
        
        required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
#endif

