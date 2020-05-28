# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## Unreleased
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
