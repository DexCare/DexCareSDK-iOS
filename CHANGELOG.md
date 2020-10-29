# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## 3.0.2

### Changed/Updated
- Makes all public models inherit from `Codable`. Previously some public models were just set as `Decodable`. This should help in using the DexcareSDK with ReactNative.

### Fixes
- Chats inside a virtual visit (not in waiting room) did not successfully decode when a provider sent a message (DC-2947)

## 3.0.1

### Fixes
- Updated podspec to included updated 2.18 OpenTok pod
- When in Virtual Chat the message from device should be on the right side and different color. (DC-2794)

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

## [2.0.6]
### Changed
- Updated header key for fhirorch calls to `X-api-key` from `x-api-keys`

## [2.0.5]
### Changed
- Coupon code verification endpoint updated to **/api/v2/coupon/{couponCode}/verify**

## [2.0.4]
### Changed
- Removed build number from version included in User-Agent for DexCare service network requests. The version is now valid SemVer.

## [2.0.3]
### Fixed
- Require user email for virtual visit requests as fallback in case patient data does not include email

## GAP IN CHANGELOG through 2.0.2
### Added
- Required preTriageTags parameter for virtual visit booking

### Changed
- Compiled with Swift 5 & Xcode 11

## [1.2.0]
### Added
- Official support of virtual visit using OpenTok

## [1.0.8]
### Changed
- bug fixes for open tok virtual visit

### Added
- Region busy is now a failed reason when scheduling virtual visit.

## [1.0.7]
### Added
- Region busy and busy message for `regionAvailability` and `regions` in virtual service

## [1.0.6]
### Added
- Optional custom strings configuration for waiting room copy

## [1.0.5]
### Changed
- Virtual visit: allow toggling of front and back camera
- Virtual visit: Feedback service parameters updated
