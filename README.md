# iOS DexCareSDK

Contains the source framework of the iOS DexcareSDK for express care services.

## Swift Package Manger

iOS SDK is available via SPM.

To install, add the following url to your dependencies `https://github.com/DexCare/DexCareSDK-iOS/` being sure to target `9.1.1` or greater

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
  'FittedSheets' - Controls the presentation of the virtual visits
```

## Privacy Manifest

Apple requires all apps and SDKs to provide a [privacy manifest file](https://developer.apple.com/documentation/bundleresources/privacy_manifest_files). The DexCare SDK contains multiple APIs, making it hard for us to create a manifest file with all the "Privacy Nutrition Label Types" as it depends on which APIs you will use. If you want to see an example of a manifest file, please look at our [SampleApp](https://github.com/DexCare/DexCareSDK.iOS.SampleApp).  

Here is the data we collect as part of our booking processes (Virtual, Provider, or Retail):
- **Name**: Used to book a visit.
- **Email Address**: Used to book a visit.
- **Phone Number**: Used to book a visit.
- **Physical Address**: Used to book a visit.
- **Other Diagnostic Data**: Used to help troubleshoot issues that could arise while using any of our APIs.

If you still have questions or need clarifications, please contact your implementation team. 

## Changelog

Latest changes can be found in the [Changelog](changelog.md)

