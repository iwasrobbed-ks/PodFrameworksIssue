# PodFrameworksIssue

Address how to avoid duplicating classes while using internal dynamic frameworks that embed static frameworks (frameworks that host a static library) or static libraries pods like in CocoaPods 1.5.x.

Related issues:
 - https://github.com/CocoaPods/CocoaPods/issues/5768
 - https://github.com/CocoaPods/CocoaPods/issues/7938

## Typical Setup

See the `master` branch.

```
MyApp
-- embeds MyAmazingFramework
-- embeds MyOtherAmazingFramework
-- depends on PodA

MyAmazingFramework
-- depends on PodA

MyOtherAmazingFramework
-- embeds MyAmazingFramework
-- depends on PodA
```

e.g.

```
workspace 'PodFrameworks.xcworkspace'

# Note: we use static libs for all pods
def shared_pods
  pod 'Switchboard'
end

target 'AppOne' do
  project 'AppOne/AppOne.xcodeproj'

  shared_pods
end

target 'MyAmazingFramework' do
  project 'MyAmazingFramework/MyAmazingFramework.xcodeproj'

  shared_pods
end

target 'MyOtherAmazingFramework' do
  project 'MyOtherAmazingFramework/MyOtherAmazingFramework.xcodeproj'

  shared_pods
end
```

Doing this, the lib is duplicated across both the frameworks and the app targets
>Class PodsDummy_Switchboard is implemented in both MyAmazingFramework.framework/MyAmazingFramework and MyOtherAmazingFramework.framework/MyOtherAmazingFramework. One of the two will be used. Which one is undefined.
>Class PodsDummy_Switchboard is implemented in both MyOtherAmazingFramework.framework/MyOtherAmazingFramework and MyApp.app/MyApp. One of the two will be used. Which one is undefined.

## Preferred Setup

See the `deduped` branch.

Make your internal frameworks into local pods and let CocoaPods link everything properly without duplicating static libraries.

```
workspace 'PodFrameworks.xcworkspace'

# Note: we use static libs for all pods
target 'AppOne' do
  project 'AppOne/AppOne.xcodeproj'

  pod 'Switchboard'
  pod 'MyAmazingFramework', path: 'MyAmazingFramework'
  pod 'MyOtherAmazingFramework', path: 'MyOtherAmazingFramework'
end
```
