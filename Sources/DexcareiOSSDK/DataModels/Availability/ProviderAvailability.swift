import Foundation

/// Object containing information on Provider Availability. Called using the `AvailabilityService.getProviderAvailability` methods
public struct ProviderAvailability: Codable, Equatable {
    /// The national identifier for the Provider
    public let npi: String
    /// The full name of the Provider
    public let name: String
    /// The gender of the Provider if provided
    public let gender: Gender?
    /// A list of specialties of the provider
    public let specialties: [String]
    /// The departmentId of the provider
    public let departmentId: String
    /// The name of the department of the provider
    public let departmentName: String
    /// Which EHR System this provider belongs to
    public let ehrInstance: String
    /// Address of the provider
    public let address: Address
    /// Which timezone this provider department practices in
    public let timezone: String
    /// If zip code or Latitude/Longitude are used in search, the distance from there, otherwise 0
    public let distanceFrom: Double
    /// Which Visit Types and Availability of the provider
    public let visitTypes: [ProviderVisitTypeAvailability]?
    /// What type of clinic the provider is practicing in.
    public let clinicType: String?
}

extension ProviderAvailability {
    init(npi: String, provider: AvailabilityProviderResponse, department: AvailabilityDepartmentResponse) {
        self.npi = npi
        self.name = provider.name
        if let gender = provider.gender {
            self.gender = Gender(rawValue: gender.lowercased())
        } else {
            self.gender = nil
        }
        self.specialties = provider.specialties
        self.departmentId = department.departmentId
        self.departmentName = department.departmentName
        self.ehrInstance = department.ehrInstance
        self.address = department.address
        self.timezone = department.timezone
        self.distanceFrom = department.distanceFrom
        self.visitTypes = nil
        self.clinicType = department.clinicType
    }
}
