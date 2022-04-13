source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
use_frameworks!
inhibit_all_warnings!

target 'Msea' do

  # Swift 代码规范检查
  pod 'SwiftLint', configurations: ['Debug']
  # 解析 XML/HTML
  pod 'Kanna'
  # 友盟
  pod 'UMCommon'
  pod 'UMDevice'
  
end

target 'TopicWidgetExtension' do
  pod 'Kanna'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |configuration|
      configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      configuration.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
    end
  end
end
