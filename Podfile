# frozen_string_literal: true

source 'https://github.com/CocoaPods/Specs.git'

# Default platform for most targets
platform :ios, '10.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

workspace 'PodFrameworks.xcworkspace'

# Note: we use static libs for all pods
target 'AppOne' do
  project 'AppOne/AppOne.xcodeproj'

  pod 'Switchboard'
  pod 'MyAmazingFramework', path: 'MyAmazingFramework'
  pod 'MyOtherAmazingFramework', path: 'MyOtherAmazingFramework'
end
