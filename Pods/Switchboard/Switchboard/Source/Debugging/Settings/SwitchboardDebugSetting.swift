//
//  SwitchboardDebugSetting.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import Foundation

/// Note: Types are derived from the class type (e.g. toggle, text field, etc)

internal protocol SwitchboardDebugSetting {}

// MARK: - SwitchboardToggleSetting

typealias SwitchboardDebugToggleClosure = (_ enabled: Bool) -> ()

final internal class SwitchboardToggleSetting: SwitchboardDebugSetting {

    required init(title: String, toggleHandler: @escaping SwitchboardDebugToggleClosure) {
        self.title = title
        self.toggleHandler = toggleHandler
    }

    // MARK: - Properties

    var feature: SwitchboardFeature?
    var experiment: SwitchboardExperiment?

    let title: String
    var toggledOn: Bool?
    let toggleHandler: SwitchboardDebugToggleClosure

    // MARK: - Unsupported Initializers

    required init(title: String) { fatalError("init(title:) has not been implemented") }
}

// MARK: - SwitchboardTextFieldSetting

final internal class SwitchboardTextFieldSetting: SwitchboardDebugSetting {

    required init(placeholder: String, text: String?, editable: Bool = true) {
        self.placeholder = placeholder
        self.text = text
        self.editable = editable
    }

    // MARK: - Properties

    let placeholder: String
    var text: String?
    let editable: Bool

    // MARK: - Unsupported Initializers

    required init(title: String) { fatalError("init(title:) has not been implemented") }
}

// MARK: - SwitchboardTextViewSetting

final internal class SwitchboardTextViewSetting: SwitchboardDebugSetting {

    required init(text: String? = nil) {
        self.text = text
    }

    // MARK: - Properties

    var text: String?

    // MARK: - Unsupported Initializers

    required init(title: String) { fatalError("init(title:) has not been implemented") }
}

// MARK: - SwitchboardTappableSetting

typealias SwitchboardDebugTapClosure = () -> ()

internal class SwitchboardTappableSetting: SwitchboardDebugSetting {

    required init(title: String, selected: Bool = false, tapHandler: @escaping SwitchboardDebugTapClosure) {
        self.title = title
        self.selected = selected
        self.tapHandler = tapHandler
    }

    // MARK: - Properties

    let title: String
    var selected: Bool
    let tapHandler: SwitchboardDebugTapClosure

    // MARK: - Unsupported Initializers

    required init(title: String) { fatalError("init(title:) has not been implemented") }
}

// MARK: - Equatable

extension SwitchboardTappableSetting: Equatable {

    static func ==(lhs: SwitchboardTappableSetting, rhs: SwitchboardTappableSetting) -> Bool {
        return lhs.title == rhs.title
    }

}

// MARK: - SwitchboardButtonSetting

final internal class SwitchboardButtonSetting: SwitchboardTappableSetting {

    // MARK: - Properties

    var enabled: Bool = true

}
#endif
