//
//  SwitchboardDebugFeatureEditView.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import UIKit

/// Note: this class is transactional, so all changes are temporary until the Save button is pressed
final internal class SwitchboardDebugFeatureEditView: SwitchboardDebugEditView {

    // MARK: - Instantiation

    required init(feature: SwitchboardFeature, debugController: SwitchboardDebugController, refreshHandler: @escaping SwitchboardDebugEditShouldRefresh) {
        super.init(feature: feature, experiment: nil, debugController: debugController, refreshHandler: refreshHandler)
    }

    // MARK: - Overrides

    override var editTitle: String { return "Edit Feature" }

    override var sections: [SwitchboardEditSection] {
        return [.name, .enabled, .values]
    }

    override func generateInitialRows() -> [[SwitchboardDebugSetting]] {
        // Note: the array of arrays correlates with the section this item is in
        // so the first array is the "Name" section, etc
        return [[name], [enabled], [values]]
    }

    override func formIsSaved() -> (saved: Bool, errorMessage: String?) {
        guard let newValues = valuesDictionary else {
            return (false, "Could not parse values string into a JSON dictionary. Make sure it's valid JSON.")
        }
        guard newValues[SwitchboardKeys.cohort] == nil else {
            return (false, "Features cannot have a cohort assigned in their values JSON dictionary in order to be considered a 'feature'.")
        }
        guard let feature = feature else { return (false, "No feature available to save to.") }

        debugController?.change(values: newValues, for: feature)
        if let newToggleValue = newToggleValue {
            toggle(isOn: newToggleValue)
        }
        return (true, nil)
    }

    // MARK: - Private Properties

    fileprivate lazy var name: SwitchboardTextFieldSetting = { [unowned self] in
        return SwitchboardTextFieldSetting(placeholder: "Feature Name", text: self.itemName, editable: false)
    }()
    
    fileprivate lazy var enabled: SwitchboardToggleSetting = { [unowned self] in
        return SwitchboardToggleSetting(title: "Enabled", toggleHandler: { isOn in
            self.newToggleValue = isOn
        })
    }()

    fileprivate lazy var values: SwitchboardTextViewSetting = { [unowned self] in
        return SwitchboardTextViewSetting(text: self.valuesString)
    }()

    fileprivate var valuesDictionary: [String: Any]? {
        return jsonDictionary(from: values.text)
    }

    fileprivate var newToggleValue: Bool?

    // MARK: - Unsupported Initializers

    required public init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override init(feature: SwitchboardFeature?, experiment: SwitchboardExperiment?, debugController: SwitchboardDebugController, refreshHandler: @escaping SwitchboardDebugEditShouldRefresh) { fatalError("use init(feature:debugController:refreshHandler:) instead") }

}
#endif
