Pod::Spec.new do |s|
  s.name         = 'DexcareSDK'
  s.version      = '6.1.3'
  s.platform = :ios, '12.0'
  s.swift_version = '5.0'
  s.summary      = 'DexcareSDK libary for express care services'
  s.homepage = 'https://developers.dexcarehealth.com/'
  s.license = 'private'
  s.authors = { 'Dexcare' => 'support@dexcarehealth.com'}
  s.source = {
    :git => 'https://github.com/Dexcare/DexCareSDK-iOS.git', :tag => "#{s.version}"
  }
  s.module_name = 'DexcareSDK'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  ## ---------------------------------------------------------------------------
  # Production Framework Source
  ## ---------------------------------------------------------------------------
  s.vendored_frameworks = ["Framework/DexcareiOSSDK.xcframework"]

  # DexcareSDK dependency
  s.dependency 'MBProgressHUD', '~> 1.2.0'
  s.dependency 'MessageKit', '~> 3.5.0'
  s.dependency 'PromiseKit/CorePromise', '~>6.13.1'
  s.dependency 'OpenTok', '2.19.1'

  ## ---------------------------------------------------------------------------

end
