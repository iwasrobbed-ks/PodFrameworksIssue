//
//  Switchboard.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/12/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

// Note: An abstract class is created to avoid some issues with
// default protocol implementations; more info here: http://bit.ly/2ylH4Cd

public typealias ShouldPreventExperimentClosure = (_ experimentName: String) -> Bool
public typealias ShouldPreventFeatureClosure = (_ featureName: String) -> Bool

open class Switchboard: SwitchboardClient {

    // MARK: - Instantiation

    public init() {}

    // MARK: - Public Properties

    /// Whether or not we're currently in debugging mode (managed via `SwitchboardDebugController`)
    open var isDebugging: Bool {
        get { return UserDefaults.standard.bool(forKey: debuggingKey) == true }
        set { UserDefaults.standard.set(newValue, forKey: debuggingKey) }
    }

    /// The active experiments to validate against
    open var experiments = Set<SwitchboardExperiment>()

    /// The active features that apply to this person
    open var features = Set<SwitchboardFeature>()

    /// Any inactive experiments (useful for debugging to toggle on/off)
    open var inactiveExperiments = Set<SwitchboardExperiment>()

    /// Any inactive features (useful for debugging to toggle on/off)
    open var inactiveFeatures = Set<SwitchboardFeature>()

    /// A closure that returns a bool and allows you to execute conditional logic which
    /// will prevent all or certain experiments from being returned or executed
    ///
    /// Example: if you're running other A/B tests (outside of Switchboard) and don't
    /// want to start certain (or all) Switchboard experiments, you can override it here
    open var preventExperimentFromStarting: ShouldPreventExperimentClosure?

    /// A closure that returns a bool and allows you to execute conditional logic which
    /// will prevent all or certain features from being returned as enabled
    ///
    /// Example: if you're running other A/B tests (outside of Switchboard) and don't
    /// want certain (or all) Switchboard features to be enabled, you can override it here
    open var preventFeatureFromEnabling: ShouldPreventFeatureClosure?

    // MARK: - Default Implementations

    /// Returns true if this person is in the given experiment
    ///
    /// - Parameters:
    ///   - experimentName: The experiment name to validate against
    ///   - defaultValue: A default value (should be false by default) to fall back to if no experiment by that name was found
    /// - Returns: True if that experiment was found and the person was within it
    open func isIn(experimentNamed experimentName: String, defaultValue: Bool = false) -> Bool {
        if preventExperimentFromStarting?(experimentName) == true { return false }
        if let _ = experiment(named: experimentName) {
            return true
        }
        return defaultValue
    }

    /// Returns true if this person is not in the given experiment
    ///
    /// - Parameters:
    ///   - experimentName: The experiment name to validate against
    ///   - defaultValue: A default value (should be true by default) to fall back to if no experiment by that name was found
    /// - Returns: True if that experiment was found and the person was not within it
    open func isNotIn(experimentNamed experimentName: String, defaultValue: Bool = true) -> Bool {
        if preventExperimentFromStarting?(experimentName) == true { return true }
        if let _ = experiment(named: experimentName) {
            return false
        }
        return defaultValue
    }

    /// Returns true if this person has a feature enabled for them
    ///
    /// - Parameters:
    ///   - feature: The feature to validate against
    ///   - defaultValue: A default value (should be false by default) to fall back to if no feature by that name was found
    /// - Returns: True if that feature was found and the person has it enabled for them
    open func isEnabled(featureNamed featureName: String, defaultValue: Bool = false) -> Bool {
        if preventFeatureFromEnabling?(featureName) == true { return false }
        if let _ = feature(named: featureName) {
            return true
        }
        return defaultValue
    }

    /// Returns true if this person does not have a feature enabled for them
    ///
    /// - Parameters:
    ///   - feature: The feature to validate against
    ///   - defaultValue: A default value (should be true by default) to fall back to if no feature by that name was found
    /// - Returns: True if that feature was not found or the person doesn't have it enabled for them
    open func isNotEnabled(featureNamed featureName: String, defaultValue: Bool = true) -> Bool {
        if preventFeatureFromEnabling?(featureName) == true { return true }
        if let _ = feature(named: featureName) {
            return false
        }
        return defaultValue
    }

    // MARK: - Other API

    /// Returns an experiment with the given name, if it exists (e.g. it's active and the person is within it)
    ///
    /// - Parameter name: The name of the experiment
    /// - Returns: A `SwitchboardExperiment` instance, if it exists
    open func experiment(named name: String) -> SwitchboardExperiment? {
        return experiments.filter({ $0.name == name }).first
    }

    /// Returns a feature with the given name, if it exists (e.g. it's active and the person has it)
    ///
    /// - Parameter name: The name of the feature
    /// - Returns: A `SwitchboardFeature` instance, if it exists
    open func feature(named name: String) -> SwitchboardFeature? {
        return features.filter({ $0.name == name }).first
    }

    /// Manual override point to add an active experiment
    ///
    /// Note: typically you should only set `experiments` during a network request, but this method is useful for debugging or testing
    ///
    /// - Parameter experiment: A `SwitchboardExperiment` instance
    open func add(experiment: SwitchboardExperiment) {
        experiments.insert(experiment)
        SwitchboardPrefillController.shared.add(experiment: experiment)

        #if !DEBUG
            SwitchboardLogging.logDangerousCall()
        #endif
    }

    /// Manual override point to remove an active experiment
    ///
    /// Note: typically you should only mutate `experiments` during a network request, but this method is useful for debugging or testing
    ///
    /// - Parameter experiment: A `SwitchboardExperiment` instance
    open func remove(experiment: SwitchboardExperiment) {
        experiments.remove(experiment)

        #if !DEBUG
            SwitchboardLogging.logDangerousCall()
        #endif
    }

    /// Manual override point to add an active feature
    ///
    /// Note: typically you should only set `features` during a network request, but this method is useful for debugging or testing
    ///
    /// - Parameter feature: A `SwitchboardFeature` instance
    open func add(feature: SwitchboardFeature) {
        features.insert(feature)
        SwitchboardPrefillController.shared.add(feature: feature)

        #if !DEBUG
            SwitchboardLogging.logDangerousCall()
        #endif
    }

    /// Manual override point to remove an active feature
    ///
    /// Note: typically you should only mutate `features` during a network request, but this method is useful for debugging or testing
    ///
    /// - Parameter feature: A `SwitchboardFeature` instance
    open func remove(feature: SwitchboardFeature) {
        features.remove(feature)

        #if !DEBUG
            SwitchboardLogging.logDangerousCall()
        #endif
    }

    // MARK: Overrides

    /// Called during application launch to download initial experiments
    ///
    /// - Parameters:
    ///   - serverUrlString: A url string for this target's Switchboard server instance
    ///   - completion: A closure called during success / failure
    open func activate(serverUrlString: String, completion: SwitchboardClientCompletion?) {
        fatalError("override necessary")

        // Example implementation:
        /*
         self.serverUrlString = serverUrlString

         var userData = SwitchboardProperties.defaults
         userData["someCustomKey"] = "someCustomValue"
         downloadExperiments(for: "someUuid", userData: userData, completion: completion)
         */
    }

    /// Downloads relevant experiments and features from the Switchboard server
    ///
    /// - Parameters:
    ///   - uuid: A unique user identifier
    ///   - userData: Optional user data which should be merged into the request parameters
    ///   - completion: Optional closure called upon completion
    open func downloadConfiguration(for uuid: String, userData: [String : Any]?, completion: SwitchboardClientCompletion?) {
        fatalError("override necessary")
        
        // Implement networking code here to make a request to your Switchboard server instance.
        // Once you receive a response, you'll use the JSON to instantiate
        // the experiments and features and store them on this instance
    }

    // MARK: - Private Properties

    fileprivate let debuggingKey = "com.keepsafe.switchboard.isDebugging"

}
