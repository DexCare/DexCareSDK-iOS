// Copyright © 2019 DexCare. All rights reserved.

import Foundation

extension DateFormatter {
    /// Returns a date formatter with the format "yyyy-MM-dd" (2018-01-03)
    static let yearMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        // this is changed from v2-4.x. The idea being that anything that we just want the date (ie a birthday) should just ignore timezone. So make it GMT:0
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    /// Returns a date formatter with the format "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'" (2018-07-04T18:15:32.453Z)
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        return formatter
    }()

    /// Returns a date formatter with the format "yyyy-MM-dd'T'HH:mm:ss.SSSZ" (2018-07-04T18:15:32.000+00:00)
    static let iso8601FullDetailed: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssXXXXX"
        return formatter
    }()

    static let iso8601 = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return dateFormatter
    }()

    static let iso8601NoMilliseconds = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        return dateFormatter
    }()

    static let timestamp = { () -> DateFormatter in
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter
    }()
}

extension Date {
    func asTimestampString(timeZone: TimeZone = .current) -> String {
        let dateFormatter = DateFormatter.timestamp
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: self)
    }

    func relativeTime(from date: Date) -> String {
        let (years, months, weeks, days, hours, minutes, seconds) = (yearsFrom(date), monthsFrom(date), weeksFrom(date), daysFrom(date), hoursFrom(date), minutesFrom(date), secondsFrom(date))
        if years > 0 {
            return "\(years) year" + (years > 1 ? "s" : "") + " ago"
        }
        if months > 0 {
            return "\(months) month" + (months > 1 ? "s" : "") + " ago"
        }
        if weeks > 0 {
            return "\(weeks) week" + (weeks > 1 ? "s" : "") + " ago"
        }
        if days > 0 {
            return days == 1 ? "Yesterday" : "\(days) days ago"
        }
        if hours > 0 {
            return "\(hours) hour" + (hours > 1 ? "s" : "") + " ago"
        }
        if minutes > 0 {
            return "\(minutes) minute" + (minutes > 1 ? "s" : "") + " ago"
        }
        if seconds > 15 {
            return "\(seconds) second" + (seconds > 1 ? "s" : "") + " ago"
        }
        return "Just now"
    }

    func yearsFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: self, to: date).year ?? 0
    }

    func monthsFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: self, to: date).month ?? 0
    }

    func weeksFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: date).weekOfYear ?? 0
    }

    func daysFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: self, to: date).day ?? 0
    }

    func hoursFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: self, to: date).hour ?? 0
    }

    func minutesFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: date).minute ?? 0
    }

    func secondsFrom(_ date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: self, to: date).second ?? 0
    }

    func asUTCString() -> String {
        return DateFormatter.iso8601.string(from: self)
    }
}
