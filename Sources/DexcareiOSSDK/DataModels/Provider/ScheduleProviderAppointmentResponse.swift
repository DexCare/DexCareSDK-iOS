import Foundation

/// Contains information about a scheduled Provider visit
public struct ScheduledProviderVisit: Codable, Equatable {
    /// The identifier of the provider visit.
    public let visitId: String
    /// Whether this visit will be virtual or in-person
    public let isVirtual: Bool
    /// Contains additional information about the visit when the visit is virtual.
    public let virtualMeetingInfo: VirtualMeetingInfo?

    /// Contains additional information about a virtual Provider visit.
    public struct VirtualMeetingInfo: Codable, Equatable {
        /// A URL that can be used to join the virtual visit in zoom/teams.
        public let joinUrl: URL?
        /// A shortened URL that acts the same as `joinUrl`
        public let joinUrlShort: URL?
        /// The id of the zoom/teams session the virtual visit will take place in.
        public let conferenceId: String?
        /// A toll free number to call for the visit if available
        public let tollFreeNumber: String?
        /// The password required to join the virtual conference, if applicable.
        public let password: String?
        /// An enum representing the video conference service that will be used for this virtual visit.
        public let vendor: VirtualMeetingVendor?

        enum CodingKeys: String, CodingKey {
            case joinUrl
            case joinUrlShort
            case conferenceId
            case tollFreeNumber = "tollNumber"
            case password
            case vendor
        }

        /// An internal decoder to handle dates.
        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)

            if let joinUrlString = try? values.decodeIfPresent(String.self, forKey: .joinUrl) {
                self.joinUrl = URL(string: joinUrlString)
            } else {
                self.joinUrl = nil
            }
            if let joinUrlShortString = try? values.decodeIfPresent(String.self, forKey: .joinUrlShort) {
                self.joinUrlShort = URL(string: joinUrlShortString)
            } else {
                self.joinUrlShort = nil
            }

            // Sometimes conferenceId comes down as a string, sometimes a number :(
            if let conferenceId = try? values.decodeIfPresent(String.self, forKey: .conferenceId) {
                self.conferenceId = conferenceId
            } else if let conferenceId = try? values.decodeIfPresent(Int.self, forKey: .conferenceId) {
                self.conferenceId = String(conferenceId)
            } else {
                self.conferenceId = nil
            }
            self.tollFreeNumber = try? values.decodeIfPresent(String.self, forKey: .tollFreeNumber)

            self.password = try? values.decodeIfPresent(String.self, forKey: .password)
            self.vendor = try? values.decodeIfPresent(VirtualMeetingVendor.self, forKey: .vendor)
        }

        // Initializer used only for stubbing tests
        init(
            joinUrl: URL?,
            joinUrlShort: URL?,
            conferenceId: String?,
            tollFreeNumber: String?,
            password: String?,
            vendor: VirtualMeetingVendor?
        ) {
            self.joinUrl = joinUrl
            self.joinUrlShort = joinUrlShort
            self.conferenceId = conferenceId
            self.tollFreeNumber = tollFreeNumber
            self.password = password
            self.vendor = vendor
        }

        // MARK: VirtualMeetingVendor

        /// An enum of what types of Virtual Meetings are supported. `.none` typically a DexCareSDK Virtual Visit
        public enum VirtualMeetingVendor: String, Codable, Equatable {
            case teams
            case zoom
            case none

            // translate unrecognized vendor values to .none
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                let vendorString = try container.decode(String.self)
                self = VirtualMeetingVendor(rawValue: vendorString) ?? .none
            }
        }
    }
}
