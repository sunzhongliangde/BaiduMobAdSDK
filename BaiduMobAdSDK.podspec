#
# Be sure to run `pod lib lint BaiduMobAdSDK.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'BaiduMobAdSDK'
  s.version          = '4.68'
  s.summary          = 'BaiduMobAdSDK'
  s.description      = <<-DESC
  百度移动广告SDK(百青藤)，将具有强竞争力的百度推广内容精准投放到媒体相应位置，为推广客户和流量主提供优质回报
                       DESC

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Baidu' => 'Baidu' }

  s.homepage         = 'https://github.com/sunzhongliangde/BaiduMobAdSDK.git'
  s.source           = { :git => 'https://github.com/sunzhongliangde/BaiduMobAdSDK.git', :tag => s.version.to_s }
  s.platform         = :ios, "9.0"  
  s.frameworks       = 'StoreKit', 'SafariServices', 'MessageUI', 'CoreMedia', 'CoreMotion', 'SystemConfiguration', 'CoreLocation', 'CoreTelephony', 'AVFoundation', 'AdSupport'
  s.libraries        = 'c++'

  s.vendored_frameworks = 'Frameworks/BaiduMobAdSDK.framework'
  s.resources = ['Frameworks/*.{bundle}']
  valid_archs = ['armv7', 'armv7s', 'x86_64', 'arm64']
  s.xcconfig = {
    'VALID_ARCHS' =>  valid_archs.join(' '),
  }
end
