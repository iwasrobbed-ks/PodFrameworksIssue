//
//  SwitchboardDebugController.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/25/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

#if os(iOS)
import Foundation

fileprivate final class SwitchboardDebugCache: SwitchboardCache {
    override class var cacheDirectoryName: String { return "switchboardDebug" }
}

public struct SwitchboardDebugCacheKeys {
    public static let activeKey = "active"
    public static let inactiveKey = "inactive"
}

open class SwitchboardDebugController {

    // MARK: - Instantiation

    /// Instantiates with the given `Switchboard` instance containing
    /// the server's features and experiments
    ///
    /// - Parameter switchboard: An instance of the `Switchboard` class
    /// - Parameter analytics: An optional analytics provider conforming to `SwitchboardAnalyticsProvider`
    public init(switchboard: Switchboard, analytics: SwitchboardAnalyticsProvider? = nil) {
        self.switchboard = switchboard
        self.analytics = analytics
    }

    // MARK: - Public Properties

    public let switchboard: Switchboard
    public let analytics: SwitchboardAnalyticsProvider?

    open var activeFeatures: [SwitchboardFeature] {
        return Array(switchboard.features)
    }

    open var inactiveFeatures: [SwitchboardFeature] {
        return Array(switchboard.inactiveFeatures)
    }

    open var activeExperiments: [SwitchboardExperiment] {
        return Array(switchboard.experiments)
    }

    open var inactiveExperiments: [SwitchboardExperiment] {
        return Array(switchboard.inactiveExperiments)
    }

    // MARK: - Caching

    open class func restoreDebugCache(switchboard: Switchboard, analytics: SwitchboardAnalyticsProvider?) {
        guard switchboard.isDebugging else { return }

        let (activeExperiments, activeFeatures) = SwitchboardDebugCache.restoreFromCache(namespace: SwitchboardDebugCacheKeys.activeKey)
        let (inactiveExperiments, inactiveFeatures) = SwitchboardDebugCache.restoreFromCache(namespace: SwitchboardDebugCacheKeys.inactiveKey)

        func restore(experiments: Set<SwitchboardExperiment>) -> Set<SwitchboardExperiment> {
            return Set(experiments.compactMap({ SwitchboardExperiment(name: $0.name, values: $0.values, availableCohorts: $0.availableCohorts, switchboard: switchboard, analytics: analytics) }))
        }

        func restore(features: Set<SwitchboardFeature>) -> Set<SwitchboardFeature> {
            return Set(features.compactMap({ SwitchboardFeature(name: $0.name, values: $0.values, analytics: analytics) }))
        }

        if let activeExperiments = activeExperiments {
            switchboard.experiments = restore(experiments: activeExperiments)
        }
        if let inactiveExperiments = inactiveExperiments {
            switchboard.inactiveExperiments = restore(experiments: inactiveExperiments)
        }
        if let activeFeatures = activeFeatures {
            switchboard.features = restore(features: activeFeatures)
        }
        if let inactiveFeatures = inactiveFeatures {
            switchboard.inactiveFeatures = restore(features: inactiveFeatures)
        }
    }

    open func cacheAll() {
        SwitchboardDebugCache.cache(experiments: Set(activeExperiments), features: Set(activeFeatures), namespace: SwitchboardDebugCacheKeys.activeKey)
        SwitchboardDebugCache.cache(experiments: Set(inactiveExperiments), features: Set(inactiveFeatures), namespace: SwitchboardDebugCacheKeys.inactiveKey)
        switchboard.isDebugging = true
    }

    open func clearCacheAndSwitchboard() {
        SwitchboardDebugCache.clear(namespace: SwitchboardDebugCacheKeys.activeKey)
        SwitchboardDebugCache.clear(namespace: SwitchboardDebugCacheKeys.inactiveKey)
        switchboard.experiments.removeAll()
        switchboard.inactiveExperiments.removeAll()
        switchboard.features.removeAll()
        switchboard.inactiveFeatures.removeAll()
        switchboard.isDebugging = false
    }

    // MARK: - Features API

    open func exists(feature: SwitchboardFeature) -> Bool {
        return switchboard.features.contains(feature) || switchboard.inactiveFeatures.contains(feature)
    }

    open func activate(feature: SwitchboardFeature) {
        switchboard.inactiveFeatures.remove(feature)
        switchboard.add(feature: feature)
    }

    open func deactivate(feature: SwitchboardFeature) {
        switchboard.inactiveFeatures.insert(feature)
        switchboard.remove(feature: feature)
    }

    open func delete(feature: SwitchboardFeature) {
        switchboard.features.remove(feature)
        switchboard.inactiveFeatures.remove(feature)
    }

    open func toggle(feature: SwitchboardFeature) {
        // Toggle inactive
        if let oldFeature = switchboard.feature(named: feature.name) {
            deactivate(feature: oldFeature)
            return
        }

        // Or toggle active
        activate(feature: feature)
    }

    open func change(values: [String: Any], for feature: SwitchboardFeature) {
        feature.values = values
    }

    // MARK: - Experiments API

    open func exists(experiment: SwitchboardExperiment) -> Bool {
        return switchboard.experiments.contains(experiment) || switchboard.inactiveExperiments.contains(experiment)
    }

    open func activate(experiment: SwitchboardExperiment) {
        switchboard.inactiveExperiments.remove(experiment)
        switchboard.add(experiment: experiment)
    }

    open func deactivate(experiment: SwitchboardExperiment) {
        switchboard.inactiveExperiments.insert(experiment)
        switchboard.remove(experiment: experiment)
    }

    open func delete(experiment: SwitchboardExperiment) {
        experiment.clearState() // Clear any stored state in case we add this again later
        switchboard.experiments.remove(experiment)
        switchboard.inactiveExperiments.remove(experiment)
    }

    open func toggle(experiment: SwitchboardExperiment) {
        // Toggle inactive
        if let oldExperiment = switchboard.experiment(named: experiment.name) {
            deactivate(experiment: oldExperiment)
            return
        }

        // Or toggle active
        activate(experiment: experiment)
    }

    open func change(values: [String: Any], for experiment: SwitchboardExperiment) {
        experiment.values = values
    }

    open func update(availableCohorts: [String], for experiment: SwitchboardExperiment) {
        experiment.availableCohorts = availableCohorts
    }

}
#endif
