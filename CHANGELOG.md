# Release Notes

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
- Any old deprecated functions, methods, protocols, classes from `3.0` have now been removed. It is recommended if you are coming from `2.x` to first update to `3.0` then to `3.x`

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
