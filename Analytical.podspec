Pod::Spec.new do |s|
  s.name             = 'Analytical'
  s.version          = '0.1.4'
  s.summary          = 'Analytical is a lightweight analytics library wrapper.'

  s.description      = <<-DESC
      A simple, lightweight Swift analytics abstraction layer.
                       DESC

  s.homepage         = 'https://github.com/legoless/Analytical'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Dal Rupnik' => 'legoless@gmail.com' }
  s.source           = { :git => 'https://github.com/legoless/Analytical.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/thelegoless'

  s.ios.deployment_target = '8.0'

  s.subspec 'Core' do |subspec|
    subspec.source_files = 'Analytical/Classes/Core/**/*.{swift}'
  end

  #
  # Until Google releases dynamic framework, we cannot use this, we need to manually install Google Provider. 
  #
  #s.subspec 'Google' do |subspec|
  #   subspec.source_files = 'Analytical/Classes/Provider/GoogleProvider.swift'
  #   subspec.dependency 'Analytical/Core'
  #   subspec.dependency 'Google/Analytics'
  #end

  s.subspec 'Mixpanel' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/MixpanelProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'Mixpanel-swift'
  end

  s.subspec 'Facebook' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/FacebookProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'FBSDKCoreKit'
  end
end
