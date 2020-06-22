# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased

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
