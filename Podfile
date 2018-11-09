# frozen_string_literal: true

source 'https://github.com/CocoaPods/Specs.git'

# Default platform for most targets
platform :ios, '10.0'

# Ignore all warnings from all pods
inhibit_all_warnings!

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
