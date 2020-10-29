Pod::Spec.new do |s|
  s.name         = 'DexcareSDK'
  s.version      = '3.0.2'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'
  s.summary      = 'DexcareSDK libary for express care services'
  s.homepage = 'https://developers.dexcarehealth.com/'
  s.license = 'private'
  s.authors = { 'Dexcare' => 'support@dexcarehealth.com'}
  s.source = {
    :git => 'git@github.com:Health-V2-Consortium/DexCareSDK-iOS.git', :tag => "#{s.version}"
  }
  s.module_name = 'DexcareSDK'
  s.pod_target_xcconfig = { 'SWIFT_VERSION' => '5.0' }

  ## ---------------------------------------------------------------------------
  # Production Framework Source
  ## ---------------------------------------------------------------------------
  s.source_files = "Framework/DexcareSDK.framework/Headers/*.h"
  s.public_header_files = "Framework/DexcareSDK.framework/Headers/*.h"
  s.vendored_frameworks = ["Framework/DexcareSDK.framework"]

  # DexcareSDK dependency
  s.dependency 'MBProgressHUD', '~> 1.2.0'
  s.dependency 'MessageKit', '~> 3.1.0'
  s.dependency 'PromiseKit/CorePromise', '~>6.13.1'
  s.dependency 'OpenTok', '~> 2.18.0'

  ## ---------------------------------------------------------------------------

end
