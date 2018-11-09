//
//  SwitchboardLogging.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/21/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

internal struct SwitchboardLogging {

    /// Flag for whether to log any dangerous API calls to the console; defaults to `true`
    static let logDangerousEvents = true

    /// Logs the function name for a dangerous API call made during production env
    static func logDangerousCall(functionName: String = #function) {
        guard logDangerousEvents else { return }

        #if !DEBUG
            print("[SWITCHBOARD] Dangerous API call used in production: \(functionName)")
        #endif
    }

}
