#
# Be sure to run `pod lib lint IdleTimer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IdleTimer'
  s.version          = '0.7.0'
  s.summary          = 'Easy control of UIApplication idleTimer'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
This is a class to consolidate and manipulate the Idle Timer on iOS. The double negatives make manipulating the idle timer for iOS applications confusing. This helps track the value and manipulate it easily.
                       DESC

  s.homepage         = 'https://github.com/jzucker2/IdleTimer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jordan Zucker' => 'jordan.zucker@gmail.com' }
  s.source           = { :git => 'https://github.com/jzucker2/IdleTimer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/jzucker'

  s.ios.deployment_target = '8.0'

  s.source_files = 'IdleTimer/Classes/**/*'
  
  # s.resource_bundles = {
  #   'IdleTimer' => ['IdleTimer/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
