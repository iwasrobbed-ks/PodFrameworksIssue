//
//  SwitchboardCacheable.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/19/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

/// Base protocol for creating your own implementation
public protocol SwitchboardCacheable {

    // MARK: - API

    static func cache(experiments: Set<SwitchboardExperiment>, features: Set<SwitchboardFeature>, namespace: String?)

    static func restoreFromCache(namespace: String?) -> (experiments: Set<SwitchboardExperiment>?, features: Set<SwitchboardFeature>?)
    
    static func clear(namespace: String?)

}
