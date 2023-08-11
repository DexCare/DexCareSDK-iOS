# iOS DexCareSDK

Contains the compiled framework of the iOS DexcareSDK for express care services.

## Cocoapods

iOS SDK is available via a PodSpec.

To install, add the following to your podfile.

```
 pod 'DexcareSDK', :git => 'https://github.com/Dexcare/DexcareSDK-iOS.git'
```
or if you want a specific release

```
pod 'DexcareSDK', :git => 'https://github.com/Dexcare/DexcareSDK-iOS.git', :tag => '6.1.6'
```

Cocoapods will install the following dependencies

```
  'MBProgressHUD' - Used to show a spinner when starting virtual visits
  'MessageKit' - Used in the chat view
  'OTXCFramework' - The library used when having 1:1 video conferences with your provider.
  
```

## Swift/Xcode

Starting with v6.0 will no longer work on Xcode 11 and you must upgrade to Xcode 12+ in order to use it. With this change, the framework has been upgraded to use the new `.xcframework` style of distribution. This will allow us to be more backwards compatible on swift versions going forward.





## Changelog

Latest can be found on the [Changelog](changelog.md)

