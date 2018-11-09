//
//  SwitchboardExperiment+Debug.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/27/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

internal extension SwitchboardExperiment {

    convenience init?(name: String, cohort: String, switchboard: Switchboard, analytics: SwitchboardAnalyticsProvider? = nil) {
        self.init(name: name, values: [SwitchboardKeys.cohort: cohort], switchboard: switchboard, analytics: analytics)
    }

}
