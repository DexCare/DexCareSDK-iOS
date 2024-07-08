//
// AppVersion.swift
// DexcareAppVersion
//
// Created by Reuben Lee on 2018-01-24.
// Copyright © 2018 DexCare. All rights reserved.
//

import Foundation

class DexcareAppVersion {
    /// Returns the version and build number from the main bundle if it's available, as "1.2.3 (456)"
    static var versionWithBuild: String {
        let appVersion = versionAndBuildString(format: "%1$@ (%2$@)") ?? "N/A"
        return appVersion
    }

    /// Version and build formatted into the provided `format` string.
    private static func versionAndBuildString(format: String) -> String? {
        var appVersion: String?

        if let version = version,
            let build = build {
            appVersion = String(format: format, version, build)
        }

        return appVersion
    }

    /// Current app's version if it can be loaded from the main bundle Info dictionary.
    /// Uses SemVer format, i.e. dotted Major.Minor.Patch: "1.2.3"
    /// -see: https://semver.org/#summary
    static var version: String? {
        let bundleVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return bundleVersion
    }

    /// Current app's build number if it can be loaded from the main bundle Info dictionary.
    static var build: String? {
        let bundleBuild = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String
        return bundleBuild
    }
    
    /// SDK Version
    static var sdkVersion: String? {
        let bundleVersion = Bundle.init(for: DexcareAppVersion.self).object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        return bundleVersion
    }
}
