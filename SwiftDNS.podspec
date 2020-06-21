#
# Be sure to run `pod lib lint DNS.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'SwiftDNS'
  s.version          = '0.1.0'
  s.summary          = 'make DNS query to any DNS sever directly in iOS and MacOS with Swift'

  s.description      = <<-DESC
make DNS query to any DNS sever directly in iOS and MacOS with Swift.
                     DESC

  s.homepage         = 'https://github.com/vincent178/DNS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'git' => 'vh7157@gmail.com' }
  s.source           = { :git => 'https://github.com/vincent178/DNS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'
  s.osx.deployment_target = '10.15.0'
  s.swift_version = '4.0'

  s.source_files = 'DNS/**/*'
  
  s.frameworks = 'Network'
end
