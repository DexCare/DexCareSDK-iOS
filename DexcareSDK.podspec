Pod::Spec.new do |s|
  s.name         = 'DexcareSDK'
  s.version      = '1.0.6'
  s.platform = :ios, '11.0'
  s.swift_version = '5.0'
  s.summary      = 'DexcareSDK libary for express care services'
  s.homepage = 'http://www.providence.org/'
  s.license = 'private'
  s.authors = { 'Reuben Lee' => 'reuben.lee@robotsandpencils.com'}
  s.source = {
    :git => 'git@github.com:Health-V2-Consortium/DexCareSDK-iOS.git', :tag => "1.0.6"
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
  s.dependency 'MBProgressHUD', '~> 1.1.0'
  s.dependency 'MessageKit', '~> 3.0.0'
  s.dependency 'PromiseKit/CorePromise', '~>6.4.1'
  s.dependency 'ProvidenceVideo', '~> 0.1.28'
  s.dependency 'OpenTok', '~> 2.16.4'

  ## ---------------------------------------------------------------------------

end
