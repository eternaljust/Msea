source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
use_frameworks!
inhibit_all_warnings!

target 'Msea' do

  # Swift 代码规范检查
  pod 'SwiftLint', configurations: ['Debug']
  
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
