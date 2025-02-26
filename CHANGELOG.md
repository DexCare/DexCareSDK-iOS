# Release Notes

## 9.3.2
### New
- Made `postFeedback` and feedback data models available again. 

## 9.3.1
### New
- Made `CancelReason` initializer public again.

## 9.3.0
### New

- This version introduces the ability to convert a virtual visit to a phone visit. This functionality can be triggered by the care giver when the virtual visit is experiencing any technical issues.
- When the patient closes the "Convert to Phone" CTA, the start or resume methods will return a `.phoneVisit` completion reason.
- The `onVirtualVisitModalityChanged` method was added to the `VirtualEventDelegate`. This method is called when a virtual visit is converted to a phone visit.
- New localizable strings:

| localizable.strings key | Usage |
|---|---|
| dialog_convertToPhone_success_title | CTA Title when the virtual visit was successfully converted to a phone visit. |
| dialog_convertToPhone_success_message | CTA Message when the virtual visit was successfully converted to a phone visit. |

#### Visit cancellation reason
- Cancelling a virtual visit will now require a reason to cancel the visit. Please work with your DexCare implementation team to learn how you can enable this feature for your organization.
- VirtualService has a new function `cancelVideoVisit(visitId: String, reasonCode: String)` to cancel the video  visit. The SDK will also use this function internally if patients decide the cancel the visit from  the waiting room. The `reasonCode` should come from the list of `CancelReason` returned in the  `getVisitCancellationReasons()` function. Similarly, use `cancelPhoneVisit(visitId: String, reasonCode: String, patientEmail: String)` to cancel phone visit.
- A new function `getVisitCancellationReasons()` is available in VirtualService. This function will return a list of `CancelReason` that can be presented to users to make a selection. A `CancelReason`  will have a display text that's user friendly and a code that needs to be sent back to the VirtualService to cancel the visit. `CancelReason` is localized as per device locale. Currently  supported languages are English and Spanish.

#### Post visit survey
- This version introduces a post visit survey that is seamlessly configurable. The SDK itself will present the UI to the patient once the visit is completed. The UI for the survey is configurable from the backend. The survey is not enabled by default when you update to this version. So please reach out to your DexCare implementation contact person for more details. However, please be aware of the breaking changes mentioned below for this version.

### Deprecated
- `getVirtualVisitStatus` in VirtualService is now deprecated in favor of new function  `getVirtualVisit`.
   They both share the same implementation but the new function provides more detail about the visit.

- `cancelVirtualVisit` function in VirtualService has been deprecated in favor of the new
  `cancelVideoVisit`  and `cancelPhoneVisit` functions.

### Breaking
- With the introduction of new web based post visit survey, this version removes the support for `postFeedback` from `VirtualService`. This function is no longer needed and your app doesn't have to implement the UI for survey. DexCare SDK will display the survey after the visit is concluded. Please reach out to your DexCare contact to understand more on configuring the web based survey.

### Bug fixes
- Fixes issue where sdkVersion was returning nil when integrated via SPM
- Fixes issue where chat message `creationDate` epoch timestamp contained decimal places
- Display number instead of words for wait time period in virtual visit waiting room

   
## 9.2.1
### Bug Fixes
- Fixed issue where app would crash when receiving chat messages while backgrounded

## 9.2.0
### New
- This version of the SDK adds support for wait offline. This gives the patient the option to close the app, remain in the wait queue, and be notified when their provider is ready for them. To accomplish this, we've added a number of things:
- New localizable strings:
  | localizable.strings key | Usage|
  |---|---|
  |waitingRoom_link_waitOffline| CTA to enter the wait offline state |
  |waitingRoom_message_waitOfflinePrompt| Prompt to explain the wait offline CTA |
  |waitingRoom_waitOffline_title| Title shown when the patient successfully enters the wait offline state |
  |waitingRoom_waitOffline_message| Message shown when the patient successfully enters the wait offline state |
  |dialog_waitOffline_title| Title for the wait offline confirmation dialog |
  |dialog_waitOffline_message| Message for the wait offline confirmation dialog |
  |dialog_waitOffline_stay| Dialog action to not enter wait offline and remain in the waiting room |
  |dialog_waitOffline_stay| Dialog action to enter the wait offline state and come back later |
  |dialog_waitingRoom_button_confirm| Replaces `dialog_waitingRoomCancelConfirm_button_confirm` as the generic confirm action in dialogs |
- New `VisitStatus.waitOffline` case: Indicates that the patient is waiting offline and waiting for a notification to rejoin the visit.
- New `VisitCompletionReason.waitOffline` case: Used in the visit completion block to indicate the user chose to wait offline and close the visit for now.

### Changes
- New `VisitStatus.caregiverAssigned` case: Indicates that a caregiver was assigned to the visit and that the visit is ready to start.
- Gave the alerts shown by the SDK a facelift to provide better extensibility options in the future.
- Updated the `dialog_waitingRoomCancelConfirm_button_confirm` localizable strings key to `Cancel visit and leave`
- Added a Privacy manifest file `PrivacyInfo.xcprivacy` to the SDK. The SDK privacy manifest file does not include Nutrition Labels as these entries will depend on which API you are using. Refer to the README.md file for more information.

### Bug fixes
- Fixed issue where the Chat View back button was not visible when the Navigation Bar global tint color was white.

### Breaking

- `WaitTimeFailedReason.regionUnavailable` enum case was replaced by: 
   - `WaitTimeFailedReason.regionBusy`: Returned when region is experiencing high demand.
   - `WaitTimeFailedReason.offHours`: Returned when the region is off hours / closed.
- New `WaitTimeFailedReason.visitNotFound` case: Returned when the given `visitId` is not found. 

## 9.1.1
### Bug Fixes
- Fixed virtual visit crash when integrating the SDK using Service Package Manager (SPM).
- Fixed issue where canceling a virtual visit was taking multiple seconds before dismissing the waiting room screen.
- Fixed issue where localization strings were not available when integrating the SDK using CocoaPods.
- Added server logs to track the "Index out of range" error in ChatViewController.messageForItem(IndexPath, MessagesCollectionView).

## 9.1.0
### New
This version of the SDK adds support for virtual visit transfers between providers. To accomplish this we've added a number of things:

- New Localizable strings:

  | localizable.strings key                                     | Usage|
  |-------------------------------------------------------------|---|
  | waitingRoom\_link\_leaveVisit.                                 | CTA to leave a visit after being transferred back to the waiting room |
  | waitingRoom\_message\_patientTransfer                          | Message shown only after being transferred back to the waiting room |
  | waitingRoom\_message\_dismiss                                  | CTA to dismiss the above message |
  | dialog_waitingRoomCancelConfirm_title_leaveCall              | Dialog title to confirm the user wants to leave the call |
  | dialog\_waitingRoomCancelConfirm\_message\_leaveCallConfirmation| Dialog message to confirm the user wants to leave the call |

- `VirtualEventDelegate.onWaitingRoomTransferred` Called when the user is transferred back to the waiting room after already being in a call
- `VisitCompletionReason.left` Used in the visit completion block to indicate the user chose to leave the visit

## 9.0.0
### New
- Support for Swift Package Manager
- Library is now released as source code instead of a binary package
- Added `PracticeRegionDepartment` which is now returned as part of `getVirtualPractice(practiceId:)`

### Removals
- `getCatchmentArea(visitState:, residenceState:, residenceZipCode:, brand:)` and `CatchmentArea` have been removed, see v9 migration guide for more information
- `PaymentMethod` enum cases have been simplified, see v9 migration guide for more information.
- Creating a `PaymentMethod` via insurance card has been removed along side `InsuranceCardFailedReason`
- Virtual visit customization via `CustomStrings` has been removed, see v9 migration guide for more information
- All other previously deprecated symbols have been removed. They are:
  - `AllowedVisitType.init`
  - `EmailValidator.EMAIL_REGEX_FROM_CONFIG`
  - `EmailValidator.EMAIL_VALIDATION_REGEX`
  - `OpenDay.init`
  - `OpenHours.init`
  - `PatientDemographics.init`
  - `PhoneValidator.PHONE_VALIDATION_REGEX`
  - `PracticeRegionAvailability.init`
  - `Provider.init`
  - `ProviderDepartment.init`
  - `ProviderService.getProviderTimeslots`
  - `ProviderTimeSlot.init`
  - `ProviderVisitType.init`
  - `RetailDepartment.init`
  - `RetailService.scheduleRetailAppointment`
  - `ScheduleDay.init`
  - `ScheduledProviderVisit.init`
  - `ScheduledProviderVisit.VirtualMeetingInfo.init`
  - `ScheduledVisit.init`
  - `ScheduledVisit.AppointmentDetails.init`
  - `ScheduledVisit.Timestamps.init`
  - `VirtualPractice.init`
  - `VirtualPractice.PracticePaymentAvailability.init`
  - `VirtualPracticeRegion.init`
  - `VirtualPracticeRegion.pedatricsAgeRange`
  - `WaitTime.init`
  - `WaitTimeLocalizationInfo.init`
  - `ZipCodeValidator.ZIP_CODE_VALIDATION_REGEX`

## 8.5.0
### Bug fixes
- Fixed `VirtualPracticeRegion.pedatricsAgeRange` not being decoded from the network response
- `ScheduleRetailAppointmentRequest.init` is no longer optional. All errors are now thrown

### Other
- Update TokBox to `OTXCFramework` version 2.25.1

### Clean up
We've fixed a number of misspelled symbols in this release and marked many the incorrectly spelled symbols as deprecated. We've also renamed a few symbols to better align with standard Swift naming conventions. All these symbols provide 1 click fixes via Xcode and will be removed completely in the next release. There are also a few cases of misspellings that are impossible to deprecate while leaving the original intact, these will be removed with fixit's available in the next release as well. Further, we've deprecated a number of initializers for objects that should only be constructed via `Codable`. If you feel any of these should remain, please reach out to us.

For reference the deprecated symbols are:
- `AllowedVisitType.init`
- `EmailValidator.EMAIL_REGEX_FROM_CONFIG`
- `EmailValidator.EMAIL_VALIDATION_REGEX`
- `OpenDay.init`
- `OpenHours.init`
- `PatientDemographics.init`
- `PhoneValidator.PHONE_VALIDATION_REGEX`
- `PracticeRegionAvailability.init`
- `Provider.init`
- `ProviderDepartment.init`
- `ProviderService.getProviderTimeslots`
- `ProviderTimeSlot.init`
- `ProviderVisitType.init`
- `RetailDepartment.init`
- `RetailService.scheduleRetailAppointment`
- `ScheduleDay.init`
- `ScheduledProviderVisit.init`
- `ScheduledProviderVisit.VirtualMeetingInfo.init`
- `ScheduledVisit.init`
- `ScheduledVisit.AppointmentDetails.init`
- `ScheduledVisit.Timestamps.init`
- `VirtualPractice.init`
- `VirtualPractice.PracticePaymentAvailability.init`
- `VirtualPracticeRegion.init`
- `VirtualPracticeRegion.pedatricsAgeRange`
- `WaitTime.init`
- `WaitTimeLocalizationInfo.init`
- `ZipCodeValidator.ZIP_CODE_VALIDATION_REGEX`

## 8.4.0
### New
- `PaymentMethod.insuranceManualSelfWithPayor` now takes in more insurance information. `payorId` (replaces `providerId`), and `payorName`
- `PaymentMethod.insuranceManualOtherWithPayor` now takes in more insurance information. `payorId` (replaces `providerId`), `payorName` and `subscriberId`
- Added `getEMRPatient` to `PatientService` to allow loading a patient information using a MyChartSSO authentication token 

### Deprecations
- `PaymentMethod.insuranceManualSelf` has been deprecated in favor of using `PaymentMethod.insuranceManualSelfWithPayor`. `payorId` is the new property to to pass in the insurance payor id. 
- `PaymentMethod.insuranceManualOther` has been deprecated in favor of using `PaymentMethod.insuranceManualOtherWithPayor`. `payorId` is the new property to to pass in the insurance payor id. 

## 8.3.0
### New
- Added `RetailService.getRetailDepartment` to load information on a single retail department.
- Default Waiting Room video has been updated to load from Vimeo, supporting Spanish localization. Waiting Room video can still be overridden through the `VirtualConfig` property on initialization. 

### Other
- Fixed a scenario where the SDK version posted inside the userAgent header on api calls was incorrect
- Updated OpenTok to 2.24.0
- SDK is built with Xcode 14.1, supporting iOS 13+

## 8.2.0
### New
- `PaymentMethod.insuranceManualSelf` and `PaymentMethod.insuranceManualOther` now take in an optional `insuranceGroupNumber` property.
- Added new `ScheduleProviderAppointmentFailedReason.patientNotOnPhysicalPanel`. Will return if on `ProviderService.scheduleProviderVisit` provider requires that the patient be on their panel.
- Added `VirtualVisitDetails.additionalDetails` property to allow saving of meta/extra information on a visit.

### AvailabilityService
- Included is a new `AvailabilityService` which allows you to search for an available provider, by location, or department. Options include sorting by most available, giving the ability to give time slots to lesser booked providers
- Time slots can also be searched with similar functionality. 

### Fixes
- Update internal endpoint for provider bookings with insurance to save the appointment notes properly (ENG-1040) 

### Other
- Updated OpenTok to 2.23.1

### Deprecations
- `PaymentService.uploadInsuranceCard` has been deprecated as it's no longer supported
- `PaymentMethod.insuranceImageSelf` and `PaymentMethod.insuranceImageOther` has been deprecrated as it's no longer supported.

## 8.1.0
### New
- Support for localization. To override the SDK keys, simply create a `Localizable.strings` file, match the keys used by the SDK, and the SDK will look there first for any overrides. 
- Added `VirtualVisitDetails.traveling` boolean property.

### Fixes
- On Visit creation, when using DexCarePatient, check mobile and work phone, not just homePhone (DC-9929)
- On a reconnection scenario, the SDK may crash when the provider leaves and returns. (DC-10218)

### Deprecations
- `CustomStrings` has been deprecated. Any previous use of customStrings will be used first over `Localizable.strings` file, but will be removed in a future version.

### Other
- Updated OpenTok to 2.23.0.

## 8.0.1
### New
- New `VirtualVisitFailedReason.invalidRequest(message:)` added to better show the error returned by the server if 400 returned. See message returned for specific error.

### Fixes
- Fixes MessageKit dependency version misalignment
- Removes hardcoded `VirtualVisitAssignmentQualifier.adult` and `VirtualVisitAssignmentQualifier.pediatric` options. Regular virtual visits without special qualifications, should set the `VirtualVisitDetails.assignmentQualifiers` to `nil`
- Removes missed async version of `RetailService.getClinics` this was renamed to `RetailService.getRetailDepartments`

## 8.0.0
### New
- 2 new `VirtualService.createVirtualVisit` methods have been added.
  - Both take in the new `VirtualVisitDetails`
  - One will use the existing `DexcarePatient`
  - One will use the new `EhrPatient`
- `VirtualVisitDetails` replaces the deprecated `VirtualVisitInformation`. Please see documentation for more information on the properties.
- Added `VirtualService.getWaitTimeAvailability` to fetch the new `WaitTimeAvailability` array. See documentation for more ways to filter the results.
- Added `VirtualService.getAssignmentQualifiers` to fetch the array of `VirtualVisitAssignmentQualifier` to use in `getWaitTimeAvailability` or create Visit
- Added `VirtualService.getModalities` to fetch the array of `VirtualVisitModality` to use in `getWaitTimeAvailability` or create Visit
- Added `VirtualVisitFailedReason.visitTypeNotSupported` - returned when you try and call `VirtualService.resumeVirtualVisit` with a non-virtual visit type.
- Added `VirtualPracticeRegion.pedatricsAgeRange` to indicate the age of patients that pediatric providers can see. 

- Upon signing in to the SDK, some validation configs are pulled down from the server. This allows for the validation to be consistent across DexCare platforms, and also allows for the validation requirements to be configurable per-environment. This currently only affects the EmailValidator, but may be expanded to other areas in a future SDK version.
- A new `EmailValidator.EMAIL_REGEX_FROM_CONFIG` is available to get the latest email regex the SDK will use. This will default to `EmailValidator.EMAIL_VALIDATION_REGEX`.
- A new `DexcareSDK.getStatusPage` is available to asynchronously grab the current status of the DexCare Platform. You can use this method to check for any incidents or scheduled maintenances on our infrastructure.
- `VisitStatus` has been switched from an **enum** to a **struct** that inherits from `RawRepresentable`. 
- An optional `VirtualVisitDetails.initialStatus` property has been added to support setting an initial Visit Status on a virtual visit. 

### Phone Visits
- 8.0 supports the ability to schedule a phone visit. Similar to virtual visits, except the provider will end up phoning instead of using the virtual video platform
- On `VirtualService.createVirtualVisit` simply set the `VirtualVisitDetails.visitTypeName = "phone"`
- **IMPORTANT The SDK will return in the completion event with `VisitCompletionReason.phoneVisit` after a successful creation or a resume** It is up to you to check for that result and handle appropriately.

### Swift Concurrency
Included in 8.0 is support for [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html) on all public functions. Both concurrency and closure-based functions will be supported. Internally, the SDK has moved to Concurrency for all internal calls and therefore **we have removed PromiseKit as a required Dependency**. 

For more examples of how you can call the new functions, please look at the v8 migration guide.

### Fixes
- `VisitStatus.isActive` function is now a proper public function (DC-6006)
- `PatientDemographics.birthDate` is now validated for future dates (DC-5904)
- NavigationBar on Waiting Room sometimes would not show and be transparent on iOS15 (DC-8901)

### Deprecations
- `ProviderService.getProviderTimeslots` passing in `visitTypeId` is deprecated in favour of `ProviderService.getProviderTimeslots` and passing in a `VisitTypeShortName` instead

### Removals
- `VirtualService.startVirtualVisit` - use the new `VirtualService.createVirtualVisit` passing in the new `VirtualVisitDetails`
- `VirtualVisitInformation` - use `VirtualVisitDetails` with the new `VirtualService.createVirtualVisit`
- `PracticeService.getVirtualPracticeRegionAvailability` - use the new `VirtualService.getWaitTimeAvailability`
- `PracticeService.getEstimatedWaitTime` - use the new `VirtualService.getWaitTimeAvailability`
- `RegionAvailability` - use the new `WaitTimeAvailability` returning from `VirtualService.getWaitTimeAvailability`
- `PatientService.createPatientWithMyChart` has been removed and can no longer be called.
- Removed `VirtualVisitFailedReason.deprecated`
- `RetailService.getClinics` has been renamed to `RetailService.getRetailDepartments` which in turn return `RetailDepartments` from the previous `Clinics`
- `ClinicTimeslots` have been renamed to `RetailAppointmentTimeSlots` 
- `ScheduleVisit.clinic` has been renamed to `ScheduleVisit.retailDepartment`

### Other
- Updated internal endpoint for `VirtualService.getEstimatedWaitTime`
- Updated internal endpoint for `VirtualService.getVirtualVisitStatus`
- Updated internal endpoint for `VirtualService.cancelVirtualVisit`
- Updated internal endpoint for `PracticeService.getVirtualPractice`
- Updated OpenTok dependency to 2.22.3
- Updated MessageKit dependency to 3.8.0

## 7.2.0
### New
- Adds a `PatientService.deletePatientAccount` to start the process of deleting a DexCare Patient Account.
- Upon signing in to the SDK, some validation configs are pulled down from the server. This allows for the validation to be consistent across DexCare platforms, and also allows for the validation requirements to be configurable per-environment. This currently only affects the EmailValidator, but may be expanded to other areas in a future SDK version.
- A new `EmailValidator.EMAIL_REGEX_FROM_CONFIG` is available to get the latest email regex the SDK will use. This will default to `EmailValidator.EMAIL_VALIDATION_REGEX`.

### Fixed
- Adjusts the QR Code that is displayed for TytoCare setup when it sometimes gets cut off - DC-6766

### Other
- Updated OpenTok dependency to 2.21.2

## 7.1.1
### Fixed
- Fixes a crash that happens on iOS version < 14.0. Minimum iOS version is now iOS 13+

## 7.1.0
### New
- Introduced a new `VideoCallStatistics` structure that can return network statistics about a video visit. Statistics are automatically gathered during a visit by the SDK, and can be queried by you after a visit is complete.
- `VideoCallStatistics` includes information about packet loss, bandwidth speeds, and bytes send/received. This should be used for your debugging or logging purposes.
- These statistics can be retrieve by calling `VirtualService.getVideoCallStatistics()` after a video visit has started.
- Added a new `VirtualService.getVirtualVisitStatus(visitId:)` that will return a `VisitStatus` enum. A helper function `isActive` is also added to `VisitStatus` to indicate whether or not you can resume with that visitId or not.
- Added a `[PatientQuestion]` array to the `RetailVisitInformation` and `ProviderVisitInformation` object. This can be used during retail and provider visits to pass up information to be saved.

**Important**
- When booking for retail, virtual, or provider, the visitDetails.`contactPhoneNumber` **will be the only** valid phone number needed. In previous versions, on someone else visits, the demographic.homePhone was required to be valid. Going forward, the SDK will only use `contactPhoneNumber`. If the phone number is different between the demographic.homePhone and the contactPhoneNumber then in Virtual Visits, the PRR will see the difference and can adjust the EPIC record if needed.

It is recommended that on intake, you provide a Phone Number field that can be prepopulated with whichever phone you wish. That phone number should be saved to the visitDetails.contactPhoneNumber on booking.

### Fixed
- When a network issue occurs during a video visit or in the waiting room, the SDK now extends it's retry time to 2 minutes. During this time a reconnecting spinner is shown to the user, which includes a cancel option. Tapping cancel can allow the user to leave the video visit, but does not mark the visit as cancelled and is still active. Users can rejoin the video visit.

### Other
- Updated internal endpoint for `ProviderService.getProviderTimeslots`
- When starting a virtual visit, internally the SDK will send a notification to the server to indicate that the device has enabled their video and microphone.

## 7.0.1
### Fixed
- Fixes a crash that happens on iOS version < 14.0. Minimum iOS version is now iOS 13+

## 7.0.0
### New
- Introduced a new `VirtualEventDelegate` protocol that can optionally be set on `VirtualService.setVirtualEventDelegate(delegate?)` to listen for various events while the patient is inside the waiting room/video conference. Note that the delegate should primarily be used for logging purposes.
- Added `PracticeService.getEstimatedWaitTime(practiceRegionId)` function to retrieve the estimated wait time of a practice region.
- Added `VirtualService.getEstimatedWaitTime` function to retrieve the estimated wait time when you're in a visit waiting room. This was previously internal and was called and displayed on the waiting room view
- Added `CustomizationOptions.validateEmails` that if set to **false** will skip any email validation the SDK uses. You can set the customization through the `DexcareSDK.customizationOption` property after initialization. **Defaults to TRUE** for backwards compatibility. Epic is still the final validation for emails and you should use this property in sync in how your Epic server validates email. This will skip **ALL** email validation (not including empty fields) - so it is up to you to validate any emails if this property is set to false. The email validation SDK uses can be found at `EmailValidator.EMAIL_VALIDATION_REGEX`.
- `ZipCodeValidator` (and the SDK as a result) now accepts 9-digit zip codes in addition to 5-digit zip codes. A hyphen is **required** for 9-digit zips.
- `ZipCodeValidator.ZIP_CODE_VALIDATION_REGEX` has been added. This is the Regex string used in the `ZipCodeValidator.isValid` class function.
- When booking for retail, virtual, or provider, the SDK now checks for valid zip codes and returns error if it does not pass validation

### Breaking
- `VisitType`
  - `VisitType` has been renamed to `VisitTypeShortName` and switched from an **enum** to a **struct** that inherits from `RawRepresentable`.
  - This is to allow future `VisitType`s to be created, without the need of new SDK's.
  - Old enum values have been switched to static variables: ex: `public static let illness = VisitTypeShortName(rawValue: "Illness")`
  - `ProviderService.getMaxLookaheadDays` now accepts a `VisitTypeShortName` instead of an `AllowedVisitType`, (no functional change)
  - `RetailService.getTimeSlots` method's `allowedVisitType` parameter changed to `visitTypeShortName: VisitTypeShortName`. This means that you can retrieve time slots for any visit type you want to support, and the SDK no longer restricts to the few that were defined in the old `VisitType` enum.
  - `ProviderVisitType.shortName` type changed to `VisitTypeShortName` from String (no functional change).

- Removed the following deprecated models/methods/properties:
  - Region
  - Region.Prices
  - Region.Availability
  - VirtualService.getRegions
  - RetailService.getRetailClinics
  - RetailService.uploadInsurance
  - VirtualService.getRegionAvailability
  - VirtualService.getInsurancePayers
  - VirtualService.verifyCouponCode
  - VirtualService.startVirtualVisit methods without practiceId argument
  - VirtualVisitInformation.currentState
  - DexcareConfiguration.customStrings
  - ScheduledVisitFailedReason

### Fixed
- When posting feedback, VirtualFeedback.rating case now validates the rating option to be between 0-10.

### Other
- Updated internal endpoint for wait time.
- Updated OpenTok dependency to 2.20.0 - this update should clean up the hundreds of project warnings
- All non-network-related errors returned by the SDK are now logged for debugging purposes.

## 6.1.6

- Adjusts TytoCare setup views for smaller devices
- When opening Chat, the keyboard no longer automatically opens.

## 6.1.5

- New functionality was not available publicly.
- Fixed a crash on launch

### New
- Added a new optional parameter to the `CustomizationOptions` model, `VirtualConfig`. This new model contains various customization options related the the virtual visit experience.
`VirtualConfig` currently has two optional parameters:
   - `showWaitingRoomVideo` - Whether or not to display the video on the waiting room. Defaults to `true`.
   - `waitingRoomVideoURL` - A bundle url that can be optionally specified to change the video that displays inside the virtual waiting room. When not specified, the default video is used (the same video that has always played in the waiting room, no changes). See documentation for more detail and example.
 When these properties or `VirtualConfig` are not explicitly overridden, the default values are used.

### Deprecated
- Deprecated `DexcareConfiguration.init` where you pass in the deprecated `CustomStrings`. A new init is available to use without `CustomStrings`. Any custom strings should now be passed through `DexcareSDK.customizationOption`

### Other
- Removed some public classes and functions that should be internal only
- Updated MessageKit to 3.6.0

## 6.1.1

- Fixes crash when going into waiting room

## 6.1.0
### New
- Added support for TytoCare devices in the Virtual Visit experience. When enabled on the server, a new button will appear in the waiting room and conference screens. Clicking the button will open a new that instructs the user on how to pair/connect their TytoCare device. For more information about TytoCare, visit https://www.tytocare.com/.
- New permissions are also required in order for the TytoCare integration to work:
  - The [Wifi entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_networking_wifi-info) will need to be enabled on your build.
  - Location with precise accuracy.
- If any of the new permissions are not available, the integration will still work, but the SDK will not be able to get the current Wifi network information
- `DexCareSDK.customizationOptions` now has a `tytoCareConfig` option for any TytoCare configuration that is allowed in the SDK. Please update these before starting a virtual visit.
- More information and details are available on https://developers.dexcarehealth.com/virtualvisit/tytocare

### Deprecations
- Deprecated `DexcareConfiguration.customStrings` in favour of `DexcareSDK.customizationOptions`, which can be set after initialization of the SDK and anytime before a start of a Virtual Visit.

### Changes
- When starting a virtual visit, the `VirtualVisitInformation.userEmail` will **ALWAYS** be used in the request irregardless of what is in the DexcarePatient object. This now matches retail appointments is doing. DC-4213

### Other
- Dropped support for iOS 11. Minimum iOS version is now iOS 12
- Update MessageKit to 3.5.1. InputBarAccessoryView to 5.3.0
- Updated OpenTok to 2.19.1
- Updated an internal endpoint for cancelling a virtual visit.
- Updated some public enums with the `@frozen` attribute.
  - `DexcareSDKLogLevel`
  - `Gender`
  - `PatientDeclaration`
  - `VirtualFeedback`
  - `PaymentHolderDeclaration`

## 6.0.0

### Xcode 12
- iOS SDK is now using an `.xcframework` to distribute the SDK. Xcode 11 is no longer supported. You must upgrade to Xcode 12.0+ in order to use v6.0

### Breaking
- The framework has been renamed to `DexcareiOSSDK` from `DexcareSDK`. Anywhere in your app where you `import DexcareSDK` will need be changed to `import DexcareiOSSDK`

### PaymentService
- `VirtualService.getInsurancePayers` has been deprecated and moved to `PaymentService.getInsurancePayers`
- `VirtualService.verifyCouponCode` has been deprecated and moved to `PaymentService.verifyCouponCode`,
- `RetailService.uploadInsuranceCard` has been deprecated and moved to `PaymentService.uploadInsuranceCard`
- Added a property on`DexcareSDK` instance called `paymentService`

### Other
- Dependency OpenTok updated to v2.19
- Note: You may get a LOT of warnings with v2.19. They are aware of the issue, but the warnings does not stop Virtual Visits from working.

## 5.0.0

#### Practices
- Added a new `PracticeService` to the SDK to load `VirtualPractice` Information
- `PracticeService.getVirtualPractice(practiceId)` to load information about a practice
- `PracticeService.getVirtualPracticeRegionAvailability(practiceRegionId)` to load
- Added a new `VirtualService.startVirtualVisit` which takes in the `practiceId` from the above call.
- `VirtualVisitInformation.practiceRegionId` is now required when calling the above function
- New models `VirtualPractice` ,`PracticeCareMode`, `PracticePaymentAvailability`, `VirtualPracticeRegion` have been made public

### Providers
- Added a new `ProviderService` to the SDK to load `Provider` Information.
- Added `ProviderService.getProvider(providerNationalId)` to retrieve information about a provider.
- Added `ProviderService.getProviderTimeslots(providerNationalId, visitTypeId, startDate, endDate)` to load time slots for a given provider
- Added `ProviderService.getMaxLookaheadDays(visitTypeShortName, ehrSystemName)` to get the max days the server will look ahead for time slots
- Added `ProviderService.scheduleProviderVisit(paymentMethod, providerVisitInformation, timeSlot, ehrSystemName, patientDexcarePatient, actorDexcarePatient?)` to book through a provider.
- New models `Provider`, `ProviderDepartment`, `ProviderVisitType`, `ScheduledProviderVisit`

### Other
- New `PatientService.getSuffixes` has been added to load the list of approved suffixes that can be optional used to fill in the suffix field of a `PatientDemographic.HumanName` property
- `ScheduleDay.date` is now formatted in the timezone of the Clinic/Provider. You can effectively ignore the timezone, as the property should be used for grouping of time slots.
- Changed internally the endpoint for `RetailService.getTimeSlots`
- A Virtual Visit must succeed in order to submit any feedback through `VirtualService.postFeedback`

### Deprecated
- `VirtualService.getRegions` has been deprecated in favour of the newer `PracticeService.getPractice`
- `VirtualService.getRegionAvailability` has been deprecated in favour of the newer `PracticeService.getPracticeRegionAvailability`
- `VirtualService.startVirtualVisit(with catchmentArea)` has been deprecated. Going forward use the `startVirtualVisit` method that has the practiceId.
- `VirtualVisitInformation.currentState` has been marked as deprecated and now optional. This can be set to nil when booking through Practices.

### Breaking
- Removed `PatientDemographics.actorRelationshipToPatient` property. Going forward, this property should be set from `RetailVisitInformation` or `VirtualVisitInformation` instead
- Removed deprecated `VirtualService.updatePushNotificationDeviceToken(String)` - switch to `updatePushNotificationDeviceToken(Data)` instead
- Removed deprecated `VirtualService.startVirtualVisit` that does not use catchmentArea or practiceId
- Removed deprecated `VirtualService.resumeVirtualVisit` that does not use a dexcarePatient
- Removed deprecated `PatientService.createPatient(usingVisitState)` - switch to `findOrCreatePatient(inEhrSystem)` method instead
- Removed deprecated `PatientService.createDependentPatient(usingVisitState)` - switch to `findOrCreateDependentPatient(inEhrSystem)` method instead
- Removed deprecated `PatientService.createPatient(inEhrSystem)` - switch to `findOrCreatePatient(inEhrSystem)` method instead
- Removed deprecated `PatientService.createDependentPatient(inEhrSystem)` - switch to `findOrCreateDependentPatient(inEhrSystem)` method instead
- Removed `AppointmentService.cancelRetailAppointment(appointmentId)` - switch to `.cancelRetailAppointment(visitId)` method instead
- Removed `AppointmentService.scheduleRetailAppointment()` - switch to `RetailService.scheduleRetailAppointment()` method instead
- `Environment.pcpURL` has been removed from the DexcareSDK initializer
- Removed `AppointmentService.getPCPAppointments`
- Removed `PCPAppointment` and `PrimaryCareAppointmentFailedReason`
- Made `ScheduledVisitFailedReason` enum unavailable and updated `AppointmentService.getRetailVisits` to return a `FailedReason` instead
- Removed an unused `RetailScheduledFailedReason` enum.
- Removed some unused cases in `VirtualVisitFailedReason`, `ScheduleProviderAppointmentFailedReason`, `ScheduleRetailAppointmentFailedReason`

- **`DexcarePatient.demographicLinks` has been renamed to `DexcarePatient.demographicsLinks`**
- **`PatientDemographics.ssn` has been renamed to `PatientDemographics.last4SSN`**
- **`AllowedVisitType.shortName` is now a `VisitType` enum**


### Fixed
- When passing in a nil `VirtualVisitInformation.preTriageTags` the function would return an error. This adds internally a default empty array if nil is passed in. Workaround for client in the interim is to pass in an empty array. (DC-3502)
- If a user disallows push notifications, the SDK now allows them to start a Virtual Visit. Only Microphone and Camera are required. (DC-3885)

### Dependencies
- Updated `MessageKit` to 3.3

## 4.0.3
### Fixes
- Chats inside virtual waiting room and virtual visits, were not persisting if the virtual visit was resumed (DC-3773)

## 4.0.2
### Changed/Updated
- `AppointmentService.getPCPAppointments` is marked as deprecated and will be removed in the next minor version
- `PCPAppointment` and associated objects are marked as deprecated and will be removed in the next minor version.
- `Environment.pcpURL` is marked as deprecated and the property will be removed in the next minor version

### Fixes
- Using the `RefreshTokenDelegate` now gets called properly (DC-3446)

## 4.0.1

### Changed/Updated
- `CatchmentArea.ehrSystem` and `CatchmentArea.departmentId` properties are now public

## 4.0.0

### New
- A new `AppointmentService.cancelRetailAppointment(visitId:)` method is now the method used to cancel retail visits. The old `AppointmentService.cancelRetailAppointment(appointmentId:)` is now deprecated. `VisitId` will be the id passed back in the `AppointmentService.getRetailVisits` call.
- A new `DexcareSDK.refreshTokenDelegate` delegate is now available to better handle 401 UnAuthenticated errors. When a client adopts this protocol, they have the ability to try and send a valid token (say for example if it's expired) and the network call will retry.

#### Create patient/Booking
- Creating patients and booking have been overhauled to be simpler.
- Removed the requirement to call `PatientService.createPatient(visit state or ehrSystem)` or `PatientService.createDependentPatient(visit state or ehrSystem)` and instead created new `PatientService.findOrCreatePatient` or `PatientService.findOrCreateDependentPatient`. These depend on a new `CatchmentArea` property that internally is what the SDK uses to figure out the visit state.
- `PatientService.getCatchmentArea` is now available to figure out the EHRSystem based on a visit state. If you know the EHRSystem, there is no need to call this method
- `VirtualService.startVirtualVisit` have new methods to use the new `CatchmentArea` property. You also must pass up the full `DexcarePatient` instead of the just the demographics.
- `RetailService.scheduleRetailAppointment` is new to expect a `DexcarePatient` and an optional patient for dependent if you're booking an appointment for a dependent.This replaces the old `AppointmentService.scheduleRetailAppointment`

### Breaking
- Any old deprecated functions, methods, protocols, classes from `3.0` have now been removed. It is recommended if you are coming from `2.x` to first update to `3.X` then to `4.0`

### Changed/Updated
- `RetailService.getRetailClinics` is now `RetailService.getClinics` (DC-2769)
- Added some extra validation for empty strings on some methods. (DC-2885)
- Updated an internal endpoint used by the SDK to resume virtual visits (DC-2836)
- Adds the SDK Version to the `userAgent` header for all network calls (DC-3206)
- `PatientDemographic.actorRelationshipToPatient` is deprecated. All `actorRelationshipToPatient` should now be passed in via the `RetailVisitInformation` or the `VirtualVisitInformation`
- Removed `AllowedVisitType.reasonLabel` and `AllowedVisitType.description` as they are unused

## 3.0.2

### Changed/Updated
- Makes all public models inherit from `Codable`. Previously some public models were just set as `Decodable`. This should help in using the DexcareSDK with ReactNative.

### Fixes
- Chats inside a virtual visit (not in waiting room) did not successfully decode when a provider sent a message (DC-2947)

## 3.0.1

### Fixes
- Updated podspec to included updated 2.18 OpenTok pod
- When in Virtual Chat the message from device should be on the right side and different color. (DC-2794)
_____

## 3.0.0

### Breaking
- Virtual Visits with Someone else now require `PatientDemographics.relationshipToPatient` to be set. This now matches what retail visits are requiring.
- `VirtualVisitInformation` now has a required `userEmail` property.
- `VirtualVisitInformation` now has a required `contactPhoneNumber` property.
- `VirtualVisitInformation.declaration` is now `VirtualVisitInformation.patientDeclaration`
- `RetailVisitInformation` now has a required `userEmail` property.
- `RetailVisitInformation` now has a required `contactPhoneNumber` property.

- `RetailService.uploadInsuranceCard` has been changed to return a string instead of a URL
- `PaymentMethod.insuranceImageSelf` and `PaymentMethod.insuranceImageOther` have been changed to require a new cardId instead of a URL


### New
- A new `Environment` struct has been created to simplify initialization of DexCareSDK
- `VirtualConfiguration` replaces `VirtualSDKConfiguration`
- `DexcareConfiguration` replaces `DexcareSDKConfiguration` that takes in the new `Environment` property
- `DexcareSDK.signIn(accessToken:String)` replaces `DexcareSDK.authentication.signIn`
- `DexcareSDK.signOut()` replaces `DexcareSDK.authentication.signOut`
- `VirtualService.startVirtualVisit` without email replaces the same call with email. Email property is now passed through `VirtualVisitInformation.userEmail`
- `VirtualService.resumeVirtualVisit` without email replaces the same call with email, displayName. DisplayName is now gathered automatically by SDK.
- `PatientService.createPatient` and `PatientService.createDependentPatient` now have extra validation checks for `Address.postalCode`, `homePhone`, `mobilePhone`, `workPhone`,
- New `VirtualFeedback` enum that is used in new postFeedback call
- `VirtualService.postFeedback([VirtualFeedback])` replaces `VirtualService.postFeedback(patientId...)` to simplify the postFeedback call. A `startVirtualVisit` or a `resumeVirtualVisit` must have been called before you can call this function.
- `RetailService.uploadInsuranceCard` has been changed to use a new insurance card capture (ICC) endpoint.
- `PaymentMethod.insuranceImageSelf` and `PaymentMethod.insuranceNewImageOther` have been added

### Changed/Updated
- OpenTok is now v 2.18.0
- `Dexcare.retail` has been renamed to `Dexcare.retailService`
- `Dexcare.virtual` has been renamed to `Dexcare.virtualService`
- `Dexcare.appointment` has been renamed to `Dexcare.appointmentService`
- `Dexcare.patient` has been renamed to `Dexcare.patientService`
- `VirtualSDKConfiguration` has been deprecated in favor of `VirtualConfiguration`
- `DexcareSDKBaseURL` has been deprecated in favor of `Environment`
- `DexcareSDKConfiguration` has been deprecated in favor of `DexcareConfiguration`
- `DexcareSDK.authentication` has been deprecated
- `Region.Price` struct is now `Region.Prices`. Property on `Region` is still `prices`

### Deleted
- Old deprecated `func startVirtualVisit(request: VirtualVisitRequest, presentingViewController: UIViewController, displayName: String, givenName: String, familyName: String, onCompletion: @escaping VisitCompletion, success: @escaping (String) -> Void, failure: @escaping (VirtualVisitFailedReason) -> Void)` is now removed
- Removed deprecated `VirtualVisitRequest`
- Removed unused public `VirtualFeedbackRequest`struct

### Fixes
- When in the waiting room, and the provider declines the visit, the virtual visit now closes as it should. DC-2019

## 2.3.0
### Breaking
- DexcareSDK now is built with Xcode 11.3

### Changed
- Removed header API key from calls to DIG fhirorch
- Fixes crash in ChatViewController: DC-1813
- Added VirtualService.cancelVirtualVisit

## 2.2.0

### New
- Added `getRetailVisits` to `AppointmentService`
- Added new `ScheduledVisit` model which is returned in `getRetailVisits`
- Added new `Clinic` model as a replacement for `RetailClinic`
- Note: `Clinic.departmentName` is the new property name for `RetailClinic.urlName`

### Changed
- Moved `scheduleRetailAppointment` from `RetailService` to `AppointmentService`
- Deprecated `AppointmentService.scheduleRetailAppointment` with the old `RetailTimeslot` parameter in favor of using the new `TimeSlot` parameter
- Deprecated `RetailService.appointments` which is now `AppointmentService.getRetailVisits`
- Deprecated `RetailClinic` in favor of `Clinic`
- Deprecated `RetailClinicAddress` in favor of `Address`
- Deprecated `RetailService.clinics(brandName)` in favor of `RetailService.getRetailClinics(brand)`
- Deprecated `RetailService.timeslots(clinicURLName)` in favor of `RetailService.getTimeSlots(departmentName: allowedVisitType)`
- Deprecated `RetailBookingInfo` in favor of `ClinicTimeSlot`
- Deprecated `RetailSchedulingDays` in favor of `ScheduleDay`
- Deprecated `RetailTimeslot` in favor of `TimeSlot`
- Deprecated `CancellationReason` in favor of `CancelReason`
- Moved `cancellationReasons` from `RetailService` to `AppointmentService` and renamed it to `getCancelReasons`
- Deprecated `RetailService.cancelRetailAppointment` in favor of `AppointmentService.cancelRetailAppointment` with the new `CancelReason` parameter

### Breaking
- `ScheduleDay.date` is now a `Date` type instead of a string

## [2.1.1]
### Changed
- Updated header key for fhirorch calls to `X-api-key` from `x-api-keys`

## [2.1.0]
### New
- Added new AppointmentService.
- Added AppointmentService.getPCPAppointments

### Changed
- Added PCP base url to dexcare configuration as optional.

### NOTE
- In future versions RetailService will be deprecated with functions moved over to the new AppointmentService
