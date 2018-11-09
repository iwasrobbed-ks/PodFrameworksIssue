Pod::Spec.new do |spec|
  spec.name         = 'MyOtherAmazingFramework'
  spec.summary      = 'Testing 1-2-3'
  spec.homepage     = 'https://github.com/KeepSafe/iOS'
  spec.version      = '0.1.0'
  spec.license      = { :type => 'Apache 2.0', :file => 'LICENSE' }
  spec.authors      = { 'Rob Phillips' => 'rob@getkeepsafe.com' }
  spec.source       = { :git => 'https://github.com/KeepSafe/iOS.git', :tag => "MyOtherAmazingFramework_v#{spec.version}" }
  spec.source_files = 'MyOtherAmazingFramework/**/*.swift'
  spec.ios.deployment_target = '10.0'
  spec.swift_version = '4.2'
  spec.requires_arc = true
  spec.dependency 'MyAmazingFramework'
  spec.dependency 'Switchboard'
end
