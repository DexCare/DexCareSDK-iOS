# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
## [2.0.1]
- Fix to ensure virtual visit requests fallback to a supplied email if the retrieved patient record does not include one. The startVirtualVisit call now has an added userEmail parameter to supply an email.	

## Unreleased
### Added
- Required preTriageTags parameter for virtual visit booking

### Changed
- Compiled with Swift 5 & Xcode 11

## [1.2.0]
### Added
- Offical support of virtual visit using OpenTok

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
