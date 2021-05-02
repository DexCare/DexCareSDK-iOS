# Release Notes
### 6.1.1

- Fixes crash when going into waiting room

### 6.1.0
### New
- Added support for TytoCare devices in the Virtual Visit experience. When enabled on the server, a new button will appear in the waiting room and conference screens. Clicking the button will open a new that instructs the user on how to pair/connect their TytoCare device.  For more information about TytoCare, visit https://www.tytocare.com/.
- New permissions are also required in order for the TytoCare integration to work:
  - The [Wifi entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_developer_networking_wifi-info) will need to be enabled on your build.
  - Location with percise accuracy.
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

### 6.0.0

### Xcode 12
- iOS SDK is now using an `.xcframework` to distribute the SDK. Xcode 11 is no longer supported. You must upgrade to Xcode 12.0+ in order to use v6.0

### Breaking
- The framework has been renamed to `DexcareiOSSDK` from `DexcareSDK`. Anywhere in your app where you `import DexcareSDK` will need be changed to `import DexcareiOSSDK`

### PaymentService
- `VirtualService.getInsurancePayers` has been deprecated and moved to `PaymentService.getInsurancePayers`
- `VirtualService.verifyCouponCode` has been deprecated and moved to  `PaymentService.verifyCouponCode`,
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
- Added `ProviderService.getProviderTimeslots(providerNationalId, visitTypeId, startDate, endDate)` to load timeslots for a given provider
- Added `ProviderService.getMaxLookaheadDays(visitTypeShortName, ehrSystemName)` to get the max days the server will look ahead for timeslots
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
- When passing in a nil `VirtualVisitInformation.preTriageTags` the function would return an error. This adds internally a default empty array if nil is passed in. Workaround for client in the interim is to pass in an empty array.  (DC-3502)
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
- `RetailService.getRetailClinics` is now `RetailService.getClinics`  (DC-2769)
- Added some extra validation for empty strings on some methods. (DC-2885)
- Updated an internal endpoint used by the sdk to resume virtual visits (DC-2836)
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
- `VirtualService.resumeVirtualVisit` without email replaces the same call with email, dislplayName. DisplayName is now gathered automatically by SDK.
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
- Deprecated `AppointmentService.scheduleRetailAppointment` with the old `RetailTimeslot` paramater in favor of using the new `TimeSlot` parameter
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
