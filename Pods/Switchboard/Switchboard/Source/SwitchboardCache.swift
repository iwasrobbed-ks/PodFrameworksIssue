//
//  SwitchboardCache.swift
//  Switchboard
//
//  Created by Rob Phillips on 9/19/17.
//  Copyright © 2017 Keepsafe Software Inc. All rights reserved.
//

import Foundation

public class SwitchboardCache: SwitchboardCacheable {

    // MARK: - Properties

    class var cacheDirectoryName: String { return "switchboard" }

    // MARK: - Default Implementations

    /// Caches the given experiments and features to disk, under the given namespace (e.g. `enabled`, `inactive`, etc)
    public static func cache(experiments: Set<SwitchboardExperiment>, features: Set<SwitchboardFeature>, namespace: String? = nil) {
        cache(experiments: experiments, namespace: namespace)
        cache(features: features, namespace: namespace)
    }

    /// Restores any experiments and features from disk for the given namespace (e.g. `enabled`, `inactive`, etc), if any are found, and returns them as a tuple
    public static func restoreFromCache(namespace: String? = nil) -> (experiments: Set<SwitchboardExperiment>?, features: Set<SwitchboardFeature>?) {
        let experiments = restoreExperiments(namespace: namespace)
        let features = restoreFeatures(namespace: namespace)
        return (experiments, features)
    }

    /// Clears the cache, at the given namespace (e.g. `enabled`, `inactive`, etc), of all experiments and features
    public static func clear(namespace: String? = nil) {
        let fm = FileManager.default
        if let experimentsPath = experimentsCacheDirectory(namespace: namespace) {
            try? fm.removeItem(atPath: experimentsPath)
        }
        if let featuresPath = featuresCacheDirectory(namespace: namespace) {
            try? fm.removeItem(atPath: featuresPath)
        }
    }

    // MARK: - Private Properties

    fileprivate static var cacheDirectory: String? {
        guard let cachesPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).last else { return nil }

        return createDirectory(atPath: "\(cachesPath)/\(cacheDirectoryName)")
    }

    // MARK: - Instantiation

    fileprivate init() {}

}

// MARK: - Private API

fileprivate extension SwitchboardCache {

    static func createDirectory(atPath path: String) -> String? {
        let fm = FileManager.default
        guard fm.fileExists(atPath: path) == false else { return path }

        if let _ = try? fm.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil) {
            return path
        } else {
            return nil
        }
    }

    static func experimentsCacheDirectory(namespace: String?) -> String? {
        guard let directory = cacheDirectory else { return nil }
        if let namespace = namespace {
            if let namespacedDirectory = createDirectory(atPath: "\(directory)/\(namespace)") {
                return "\(namespacedDirectory)/experiments"
            }
            return nil
        } else {
            return  "\(directory)/experiments"
        }
    }

    static func featuresCacheDirectory(namespace: String?) ->String? {
        guard let directory = cacheDirectory else { return nil }
        if let namespace = namespace {
            if let namespacedDirectory = createDirectory(atPath: "\(directory)/\(namespace)") {
                return "\(namespacedDirectory)/features"
            }
            return nil
        } else {
            return  "\(directory)/features"
        }
    }

    static func cache(experiments: Set<SwitchboardExperiment>, namespace: String?) {
        guard let directory = experimentsCacheDirectory(namespace: namespace) else { return }
        NSKeyedArchiver.archiveRootObject(experiments, toFile: directory)
    }

    static func cache(features: Set<SwitchboardFeature>, namespace: String?) {
        guard let directory = featuresCacheDirectory(namespace: namespace) else { return }
        NSKeyedArchiver.archiveRootObject(features, toFile: directory)
    }

    static func restoreExperiments(namespace: String?) -> Set<SwitchboardExperiment>? {
        guard let directory = experimentsCacheDirectory(namespace: namespace) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(withFile: directory) as? Set<SwitchboardExperiment>
    }

    static func restoreFeatures(namespace: String?) -> Set<SwitchboardFeature>? {
        guard let directory = featuresCacheDirectory(namespace: namespace) else { return nil }
        return NSKeyedUnarchiver.unarchiveObject(withFile: directory) as? Set<SwitchboardFeature>
    }

}
