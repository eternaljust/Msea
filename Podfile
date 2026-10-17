source 'https://github.com/CocoaPods/Specs.git'

platform :ios, '15.0'
# 静态链接：侧载分发要求包内不嵌套动态框架（build-ipa.sh 会校验并剥离 Frameworks/）
use_frameworks! :linkage => :static
inhibit_all_warnings!

target 'Msea' do

  # Swift 代码规范检查
  pod 'SwiftLint', configurations: ['Debug']
  # 解析 XML/HTML
  pod 'Kanna'
  # 友盟（MSEA_NO_UMENG=1 pod install 时跳过，用于无真机 slice 的模拟器构建）
  unless ENV['MSEA_NO_UMENG'] == '1'
    pod 'UMCommon'
    pod 'UMDevice'
    pod 'UMAPM'
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      if config.name == 'Debug'
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'YES'
      else
        config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
      end
    end
  end

  # CocoaPods 会向 xcconfig 写入模拟器排除 arm64 的旧兼容设置，Apple Silicon 模拟器必须去掉
  Dir.glob('Pods/Target Support Files/**/*.xcconfig').each do |path|
    content = File.read(path)
    cleaned = content.gsub(/^EXCLUDED_ARCHS\[sdk=iphonesimulator\*\].*\n/, '')
    File.write(path, cleaned) if cleaned != content
  end
end
