#
# Be sure to run `pod lib lint Analytical.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Analytical'
  s.version          = '0.1.0'
  s.summary          = 'Analytical is a lightweight analytics library wrapper.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/<GITHUB_USERNAME>/Analytical'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dal Rupnik' => 'legoless@gmail.com' }
  s.source           = { :git => 'https://github.com/<GITHUB_USERNAME>/Analytical.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.subspec 'Core' do |subspec|
    subspec.source_files = 'Analytical/Classes/Core/**/*.{swift}'
  end

  s.subspec 'Google' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/GoogleProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'Google/Analytics'
  end

#s.source_files = 'Analytical/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Analytical' => ['Analytical/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
#s.dependency 'AFNetworking', '~> 2.3'
end
