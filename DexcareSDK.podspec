Pod::Spec.new do |s|
  s.name         = 'DexcareSDK'
  s.version      = '9.3.0'
  s.platform = :ios, '14.0'
  s.swift_version = '5.0'
  s.summary      = 'DexcareSDK library for express care services'
  s.homepage = 'https://developers.dexcarehealth.com/'
  s.license = 'private'
  s.authors = { 'Dexcare' => 'support@dexcarehealth.com'}
  s.source = {
    :git => 'https://github.com/Dexcare/DexCareSDK-iOS.git', :tag => "#{s.version}"
  }
  s.module_name = 'DexcareiOSSDK'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }
  s.static_framework = true

  s.source_files = 'Sources/DexcareiOSSDK/**/*.swift'
  s.resource_bundles = {
    'DexcareSDK' => ['Sources/DexcareiOSSDK/**/*.{xib,storyboard,xcassets,strings}']
  }

  # DexcareSDK dependency
  s.dependency 'MBProgressHUD', '1.2.0'
  s.dependency 'MessageKit', '3.8.0'
  s.dependency 'FittedSheets', '2.6.1'
  s.dependency 'OTXCFramework', '2.26.2'

end
