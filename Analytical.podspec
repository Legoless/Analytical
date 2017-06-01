Pod::Spec.new do |s|
  s.name             = 'Analytical'
  s.version          = '0.5.5'
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

  s.ios.deployment_target = '9.0'

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

  #
  # Until Twitter releases dynamic framework, we cannot use this, we need to manually install Answers Provider. 
  #
  #s.subspec 'Answers' do |subspec|
  #  subspec.source_files = 'Analytical/Classes/Provider/AnswersProvider.swift'
  #  subspec.dependency 'Analytical/Core'
  #  subspec.dependency 'Answers'
  #end

  #s.subspec 'Firebase' do |subspec|
  #  subspec.source_files = 'Analytical/Classes/Provider/FirebaseProvider.swift'
  #  subspec.dependency 'Analytical/Core'
  #  subspec.dependency 'Firebase/Analytics'
  #end

  s.subspec 'Facebook' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/FacebookProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'FBSDKCoreKit'
  end

  s.subspec 'Mixpanel' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/MixpanelProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'Mixpanel-swift'
  end

  s.subspec 'Flurry' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/FlurryProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'Flurry-iOS-SDK/FlurrySDK'
  end

  s.subspec 'Log' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/LogProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'XCGLogger'
  end

  s.subspec 'Segment' do |subspec|
    subspec.source_files = 'Analytical/Classes/Provider/SegmentProvider.swift'
    subspec.dependency 'Analytical/Core'
    subspec.dependency 'Analytics'
  end

end
