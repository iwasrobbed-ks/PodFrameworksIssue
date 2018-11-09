//
//  SwitchboardPrefillController.swift
//  Switchboard
//
//  Created by Rob Phillips on 4/2/18.
//  Copyright © 2018 Keepsafe Software Inc. All rights reserved.
//

/// Longterm cache for historical Switchboard features and experiments
/// that we can use to prefill the UI with
final internal class SwitchboardPrefillCache: SwitchboardCache {
    override class var cacheDirectoryName: String { return "switchboardDebugPrefill" }
}

/// Controller for adding and removing historical features and
/// experiments used for prefilling the UI
final public class SwitchboardPrefillController {
    
    // MARK: - Instantiation
    
    public static let shared = SwitchboardPrefillController()
    
    /// Instantiates an instance and restores any features or experiments currently cached
    init() {
        restoreFromCache()
    }
    
    // MARK: - Internal Properties
    
    /// The features available to prefill from
    fileprivate(set) var features = Set<SwitchboardFeature>()
    
    /// The experiments available to prefill from
    fileprivate(set) var experiments = Set<SwitchboardExperiment>()
    
    // MARK: - Public API
    
    /// Clears all features and experiments from memory and disk
    public func clearCache() {
        features.removeAll()
        experiments.removeAll()
        SwitchboardPrefillCache.clear()
    }
    
    // MARK: - Internal API
    
    /// Populates experiments from the registered experiment names within `SwitchboardExperiment`'s
    /// static property named `namesMappedToCohorts` that keeps track of programmatically named cohorts
    ///
    /// - Parameters:
    ///   - switchboard: The `Switchboard` instance to create any new experiments within
    ///   - analytics: An optional `SwitchboardAnalyticsProvider` to associate the experiments with
    func populateExperimentsIfNeeded(in switchboard: Switchboard, analytics: SwitchboardAnalyticsProvider? = nil) {
        for (experimentName, cohorts) in SwitchboardExperiment.namesMappedToCohorts {
            guard let experiment = SwitchboardExperiment(name: experimentName, cohort: cohorts.first ?? "control", switchboard: switchboard, analytics: analytics) else { continue }
            add(experiment: experiment)
        }
    }
    
    /// Checks the given array against the prefill's features to see if there are any uniques
    ///
    /// - Parameter existingFeatures: The existing features to check again
    /// - Returns: Whether or not there are unique features in the prefill cache
    func canPrefillFeatures(for existingFeatures: [SwitchboardFeature]) -> Bool {
        return featuresUnique(from: existingFeatures).isEmpty == false
    }
    
    /// Checks the given array against the prefill's experiments to see if there are any uniques
    ///
    /// - Parameter existingExperiments: The existing experiments to check again
    /// - Returns: Whether or not there are unique experiments in the prefill cache
    func canPrefillExperiments(for existingExperiments: [SwitchboardExperiment]) -> Bool {
        return experimentsUnique(from: existingExperiments).isEmpty == false
    }
    
    /// Subtracts existing features from the prefill cache's features and returns the unique features remaining
    ///
    /// - Parameter existingFeatures: The existing features to unique from
    /// - Returns: A unique set of features they can prefill with, sorted alphabetically
    func featuresUnique(from existingFeatures: [SwitchboardFeature]) -> [SwitchboardFeature] {
        return Array(features.subtracting(existingFeatures)).sorted(by: { $0.name < $1.name })
    }
    /// Subtracts existing experiments from the prefill cache's experiments and returns the unique experiments remaining
    ///
    /// - Parameter existingFeatures: The existing experiments to unique from
    /// - Returns: A unique set of experiments they can prefill with, sorted alphabetically
    func experimentsUnique(from existingExperiments: [SwitchboardExperiment]) -> [SwitchboardExperiment] {
        return Array(experiments.subtracting(existingExperiments)).sorted(by: { $0.name < $1.name })
    }
    
    /// Adds the given features to the prefill cache
    ///
    /// - Parameter features: A `Set` of `SwitchboardFeature` objects to add and cache
    func add(features: Set<SwitchboardFeature>) {
        for feature in features {
            self.features.insert(feature)
        }
        cacheAll()
    }
    
    /// Adds the given experiments to the prefill cache
    ///
    /// - Parameter experiments: A `Set` of `SwitchboardExperiment` objects to add and cache
    func add(experiments: Set<SwitchboardExperiment>) {
        for experiment in experiments {
            self.experiments.insert(experiment)
        }
        cacheAll()
    }
    
    /// Adds the given feature to the prefill cache
    ///
    /// - Parameter feature: A `SwitchboardFeature` to add and cache
    func add(feature: SwitchboardFeature) {
        add(features: Set([feature]))
    }
    
    /// Adds the given experiment to the prefill cache
    ///
    /// - Parameter experiment: A `SwitchboardExperiment` to add and cache
    func add(experiment: SwitchboardExperiment) {
        add(experiments: Set([experiment]))
    }
    
    /// Deletes the given feature from the cache
    ///
    /// - Parameter feature: The `SwitchboardFeature` to delete from cache
    func delete(feature: SwitchboardFeature) {
        features.remove(feature)
        cacheAll()
    }

    /// Deletes the given experiment from the cache
    ///
    /// - Parameter experiment: The `SwitchboardExperiment` to delete from cache
    func delete(experiment: SwitchboardExperiment) {
        experiments.remove(experiment)
        cacheAll()
    }
    
    /// Clears all features and updates cache
    func clearFeatures() {
        features.removeAll()
        cacheAll()
    }
    
    /// Clears all experiments and updates cache
    func clearExperiments() {
        experiments.removeAll()
        cacheAll()
    }
    
}

// MARK: - Private API

fileprivate extension SwitchboardPrefillController {
    
    func cacheAll() {
        SwitchboardPrefillCache.cache(experiments: experiments, features: features)
    }
    
    func restoreFromCache() {
        let (experiments, features) = SwitchboardPrefillCache.restoreFromCache()
        if let e = experiments {
            self.experiments = e
        }
        if let f = features {
            self.features = f
        }
    }
    
}
