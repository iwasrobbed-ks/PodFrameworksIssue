# Switchboard for iOS & macOS

[![CircleCI](https://circleci.com/gh/KeepSafe/Switchboard-iOS.svg?style=svg&circle-token=92f1089eff79d10aac87afc1106eebfb10e94a85)](https://circleci.com/gh/KeepSafe/Switchboard-iOS)
[![Apache 2.0 licensed](https://img.shields.io/badge/license-Apache2-blue.svg)](https://github.com/KeepSafe/Switchboard-iOS/blob/master/LICENSE)
[![CocoaPods](https://img.shields.io/cocoapods/v/Switchboard.svg?maxAge=10800)]()
[![Swift](https://img.shields.io/badge/language-Swift-blue.svg)](https://swift.org)
[![iOS](https://img.shields.io/badge/OS-iOS-orange.svg)](https://developer.apple.com/ios/)
[![macOS](https://img.shields.io/badge/OS-macOS-orange.svg)](https://developer.apple.com/macos/)

Simple A/B testing and feature flags for iOS & macOS built on top of [Switchboard](https://github.com/KeepSafe/Switchboard).

## What it does

Switchboard is a simple way to remote control your mobile application even after you've shipped it to your users' devices, so you can use Switchboard to:

- Stage-rollout new features to users
- A/B-test user flows, messaging, colors, features, etc.
- anything else you want to remote-control

Switchboard lets you control what happens in your app in a quick, easy, and useful manner.

Additionally, Switchboard segments your users consistently; because user segmentation is based upon a UUID that is computed once, the experience you switch on and off using Switchboard is consistent across sessions.

## What it does not do

Switchboard does not give you analytics, nor does it do automatic administration and optimization of your A/B tests. It also doesn't give you nice graphs and stuff. You can get all of that by plugging an analytics package into your app which you're probably doing anyway.

There are convenient hooks for this by conforming to the `SwitchboardAnalyticsProvider` protocol and `SwitchboardExperiment` and `SwitchboardFeature` subclasses also have a convenient `track(event...)` method you can call as well. See the example app for more detail.

## Installation

Quickly install using [CocoaPods](https://cocoapods.org): 

```ruby
pod 'Switchboard'
```

Or [Carthage](https://github.com/Carthage/Carthage):

```
github "KeepSafe/Switchboard-iOS"
```

Or [manually install it](#manual-installation)

## Example Usage

There is an example app under the `SwitchboardExample` target within the project file that you can run and see the debug user interface. This debug interface comes in handy when you want to test various flows within your app (e.g. enable `featureA` and verify the code does X, then disable `featureA` and verify the code does Y) or you want to put yourself into a given experiment cohort to see what that user experience will look like to others. 

The example might also be helpful in showing you our Switchboard setup recommendations so you can more easily integrate the debug interface into your own app.

![Switchboard Debug](https://user-images.githubusercontent.com/30269720/31296028-c2812356-aa95-11e7-83c8-336266f2497e.gif)

## General Info & Usage

Note: We'll use the code in the [example app](https://github.com/KeepSafe/Switchboard-iOS/blob/master/SwitchboardExample) to walk through scenarios here.

### Experiments vs. Features

An **experiment** has at least one `cohort` of people that are within it, so think of it as an A/B test that we temporarily run in order to determine the best behavior we need for revenue goals, etc. If one of the experiments are successful, we'll delete the experiment itself and likely add its code behind a feature flag or more permanently to the codebase. 

A **feature** is exactly that: a feature that is either enabled or disabled for people. We can create feature flags to disable certain features (i.e. if we're experiencing lots of crashes in a given feature) or to expose new functionality without deploying.

### Creating an experiment

Add a new enum case to `ExampleSwitchboardExperiment ` within `ExampleSwitchboard+Example` with the name of the experiment.

You can now do things like:

```swift
if ExampleSwitchboard.isIn(experiment: .myExperiment) { }
// Or
if ExampleSwitchboard.isNotIn(experiment: .myExperiment) {}
```

If you're accessing keys within the `values` dictionary or have other complex logic that should be encapsulated nicely with this new experiment, create a subclass of `SwitchboardExperiment`.

You can now do things like:

```swift
// Note: you must cast to `MyExperiment` like shown below so it'll return the concrete type
let myExperiment: MyExperiment = ExampleSwitchboard.experiment(named: .myExperiment)
print(myExperiment.cohort)
print(myExperiment.values)
myExperiment.start()
myExperiment.complete()
// and there are lots of other helper properties and 
// functions viewable in SwitchboardExperiment

// Or do custom things
myExperiment.doSomeCustomLogicThing()
myExperiment.track(event: "somethingGreat", properties: ["wow": "magic"])

// Or you can even add experiment dependencies which prevent your experiment 
// from starting until the other experiments have been completed
myExperiment.add(dependency: someOtherExperiment)
```

If you want your cohort values to show up in the Switchboard debugging view, you can override the `availableCohorts` array in your `SwitchboardExperiment` subclass and provide the cohort strings. This will allow you to easily switch between cohorts in debugging mode and test the various UX flows.

All experiments populated using an override on `SwitchboardExperiment`'s `namesMappedToCohorts` will now auto-populate into the prefill controller so someone can explicitly add them without typing them in each time. It just requires the normal `populateAvailableCohorts()` function on each `SwitchboardExperiment` subclass to be called like normal.


### Creating a feature

Add a new enum case to `ExampleSwitchboardFeature` within `ExampleSwitchboard+Example` with the name of the feature.

You can now do things like:

```swift
if ExampleSwitchboard.isEnabled(feature: .myFeature) { }
// Or
if ExampleSwitchboard.isNotEnabled(feature: .myFeature) {}
```

If you're accessing keys within the `values` dictionary or have other complex logic that should be encapsulated nicely with this new feature, create a subclass of `SwitchboardFeature`.

You can now do things like:

```swift
let myFeature: MyFeature = ExampleSwitchboard.feature(named: .myFeature)
print(String(describing: myFeature.values))

// Or do custom things
myFeature.doSomeCustomLogicThing()
myFeature.track(event: "somethingGreat", properties: ["wow": "magic"])
```

### Caching

Switchboard caches all features and experiments, in whichever state they were last in, to the disk between sessions so that when the app is launched again we can immediately have access to them.

If the network connection is down, we'll use the cached values temporarily but otherwise we'll refresh them from the server's latest configuration.

If you made some changes via the Switchboard Debug view (described below), it will use the debug cache instead.

### Debugging

There is now a Switchboard Debug that you can use to toggle on/off features and experiments to test out different UX flows (i.e. what happens if we're in app store review, what shows if I'm part of a new pricing/ad experiment, etc). 

You can also test analytics using that by starting/completing/resetting experiments in the debug view for a given experiment.

Keep in mind that experiments are often exclusive, so running multiple experiments at once of the same type (e.g. 3 different pricing experiments) is probably a bad idea and could lead to buggy behavior in your code. It's best to disable other experiments while you're testing new ones.

Editing of the features & experiments in the debug menu is transactional, so it will only save once you hit the `Save` button (e.g. if you press start experiment, it won't start until it gets saved).

**Important Note**: Once you change something via the Switchboard debug view, Switchboard will only use the debug cache from that point forward and it will persist the changes across launches. If you want to reset back to the server, pull-to-refresh the main debug view like this:

![refresh](https://user-images.githubusercontent.com/30269720/31745766-0d95a52e-b419-11e7-9df2-8586d3c589ec.png)

## Analytics

**Cohort**: Features don't have cohorts, but experiments do. The cohort is still logged as part of an experiment when someone specifically tracks an event on an experiment. 

Example: Say we're in an experiment called "testing123" and then someone says "testing123.track(event: somethingAwesome)", then it'll log an event called `EXP_testing123_somethingAwesome` and there will be a `cohort` property attached to that event that you can segment on.

**Entitled**: The `sb::experiments_entitled` and `sb::features_entitled` user property arrays are set as soon as the Switchboard configuration is downloaded when the app loads and they list which experiments & features are entitled to start (e.g. someone is in an experiment but they haven't started it yet or someone has a feature enabled for them).

Then for experiments, you'll have a new event called `EXP_someExperimentNameHere_ACTIVATE` when they start the experiment and then `EXP_someExperimentNameHere_COMPLETED` when they complete an experiment. Keep in mind that experiments will only "start" when the person hits the point / configuration in the UX flow that triggers it to start.

Features don't start/complete. They are either enabled or disabled but that's it (e.g. app store review is either enabled or not).

**Starting/Completing**: When the activate/completed events are sent for an experiment, each of those will also have the `cohort` property attached and they'll also log additional user properties. For the `activate` (started) scenario, it'll log an array of `sb::experiments_active` with all experiments that have been started so far. For the `completed` scenario, it'll log an array of `sb::experiments_completed` with all experiments that have been completed so far. 

## Manual Installation

1. Clone this repository and drag the `Switchboard.xcodeproj` into the Project Navigator of your application's Xcode project.
  - It should appear nested underneath your application's blue project icon. Whether it is above or below all the other Xcode groups does not matter.
2. Select the `Switchboard.xcodeproj` in the Project Navigator and verify the deployment target matches that of your application target.
3. Select your application project in the Project Navigator (blue project icon) to navigate to the target configuration window and select the application target under the `Targets` heading in the sidebar.
4. In the tab bar at the top of that window, open the `General` panel.
5. Click on the `+` button under the `Embedded Binaries` section.
6. Search for and select the top `Switchboard.framework` for iOS or macOS.

And that's it!

The `Switchboard.framework` is automagically added as a target dependency, linked framework and embedded framework in a copy files build phase which is all you need to build on the simulator and a device.

## Issues & Bugs
Please use the [Github issue tracker](https://github.com/KeepSafe/Switchboard-iOS/issues) to let us know about any issues you may be experiencing.

## License

Switchboard for iOS / macOS is licensed under the [Apache Software License, 2.0 ("Apache 2.0")](https://github.com/KeepSafe/Switchboard-iOS/blob/master/LICENSE)

## Authors

Switchboard for iOS / macOS is brought to you by [Rob Phillips](https://github.com/iwasrobbed) and the rest of the [Keepsafe team](https://www.getkeepsafe.com/about.html). We'd love to have you contribute or [join us](https://www.getkeepsafe.com/careers.html).

## Used in production by

- Keepsafe (www.getkeepsafe.com)
