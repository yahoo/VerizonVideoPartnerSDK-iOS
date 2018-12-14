Pod::Spec.new do |s|
  s.name             = 'OathVideoPartnerSDK'
  s.version          = '1.0'
  s.summary          = 'Oath Video Partner SDK'
  s.license          = { type: 'MIT', file: 'LICENSE' }
  s.swift_version    = '4.2'

  s.description = <<-DESC
  SDK provides possibility to play videos, control playback, gather metrics, play ads.
  Checkout https://github.com/OathAdPlatforms/OathVideoPartnerSDK-iOS/OathVideoPartnerSDK-Tutorials for up-to-date examples.
DESC

  s.homepage         = 'https://github.com/OathAdPlatforms/OathVideoPartnerSDK-iOS'

  s.authors          = {
    'Andrey Moskvin' => 'andrey.moskvin@oath.com',
    'Alexey Demedetskiy' => 'alexey.demedetskiy@oath.com',
    'Bogdan Bilonog' => 'bogdan.bilonog@oath.com',
    'Roman Tysiachnik' => 'roman.tysiachnik@oath.com',
    'Vladyslav Anokhin' => 'vladyslav.anokhin@oath.com'
  }

  s.source           = { git: 'git@github.com:OathAdPlatforms/OathVideoPartnerSDK-iOS',
                         tag: s.version.to_s }
  s.resources        = 'support/OathVideoPartnerSDK-Version.plist'
  s.source_files     = 'sources/**/*.swift'
  s.exclude_files    = 'sources/utils/Utils.swift', 'sources/utils/Recorder.swift', 'sources/**/*Test*', 'sources/**/Contents.swift'

  s.ios.exclude_files  = 'sources/default controls'
  s.tvos.exclude_files = 'sources/custom controls', 'sources/vpaid', 'sources/metrics/open measurement'

  s.dependency 'VideoRenderer', '1.24'
  s.dependency 'PlayerCore', '1.0.1'
  s.ios.dependency 'PlayerControls', '1.26'
  s.ios.dependency 'OMSDK-Oath2', '1.0.0'

  s.ios.deployment_target  = '9.0'
  s.tvos.deployment_target = '9.0'

  s.frameworks     = 'CoreMedia', 'AVFoundation', 'CoreGraphics'
  s.ios.framework  = 'WebKit'
end
