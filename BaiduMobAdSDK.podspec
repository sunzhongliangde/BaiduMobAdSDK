#
# Be sure to run `pod lib lint BaiduMobAdSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BaiduMobAdSDK'
  s.version          = '4.69'
  s.summary          = 'BaiduMobAdSDK'
  s.description      = <<-DESC
  百度移动广告SDK(百青藤);
  http://union.baidu.com/bqt/appco.html#/union/download/sdk
                       DESC

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Baidu' => 'Baidu' }

  s.homepage         = 'https://github.com/sunzhongliangde/BaiduMobAdSDK.git'
  s.source           = { :git => 'https://github.com/sunzhongliangde/BaiduMobAdSDK.git', :tag => s.version.to_s }
  s.platform         = :ios, "9.0"  
  s.frameworks       = 'StoreKit', 'SafariServices', 'MessageUI', 'CoreMedia', 'CoreMotion', 'SystemConfiguration', 'CoreLocation', 'CoreTelephony', 'AVFoundation', 'AdSupport'
  s.libraries        = 'c++'
  s.weak_frameworks = "WebKit"
  
  s.vendored_frameworks = 'SDK/BaiduMobAdSDK.framework'
  s.resources = ['SDK/*.{bundle}']
  valid_archs = ['armv7', 'armv7s', 'x86_64', 'arm64']
  s.xcconfig = {
    'VALID_ARCHS' =>  valid_archs.join(' '),
  }
end
