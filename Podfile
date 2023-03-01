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
  pod 'UMAPM'
  
end

target 'TopicWidgetExtension' do
  pod 'Kanna'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['EXCLUDED_ARCHS[sdk=iphonesimulator*]'] = "arm64"
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      else
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      end
    end
  end
end
