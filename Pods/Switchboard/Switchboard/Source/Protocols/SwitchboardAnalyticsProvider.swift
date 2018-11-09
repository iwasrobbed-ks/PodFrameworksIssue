//
//  SwitchboardAnalyticsProvider.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

/// Base protocol for tracking analytics data for experiment state changes
public protocol SwitchboardAnalyticsProvider {

    /// Should be called after the experiments and features are downloaded and parsed
    /// so analytics can be sure of which experiments and features this person is
    /// entitled to (e.g. either to start or to have enabled)
    func entitled(experiments: Set<SwitchboardExperiment>, features: Set<SwitchboardFeature>)

    /// Should be called when the experiment was started
    func trackStarted(for experiment: SwitchboardExperiment)

    /// Should be called when the experiment was completed
    func trackCompleted(for experiment: SwitchboardExperiment)

    /// Generic tracking of an event on a given experiment
    ///
    /// - Parameters:
    ///   - event: A `String` event to track
    ///   - experiment: The `SwitchboardExperiment` to be associated with
    ///   - properties: A dictionary of optional properties
    func track(event: String, for experiment: SwitchboardExperiment, properties: [String: Any]?)

    /// Generic tracking of an event on a given feature
    ///
    /// - Parameters:
    ///   - event: A `String` event to track
    ///   - feature: The `SwitchboardFeature` to be associated with
    ///   - properties: A dictionary of optional properties
    func track(event: String, for feature: SwitchboardFeature, properties: [String: Any]?)

}
