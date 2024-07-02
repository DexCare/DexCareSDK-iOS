// Copyright © 2019 DexCare. All rights reserved.

import Foundation

extension Encodable {
    /**
     Convert this object to json data
     
     - parameter outputFormatting: The formatting of the output JSON data (compact or pretty printed)
     - parameter dateEncodingStrategy: how do you want to format the date
     - parameter dataEncodingStrategy: what kind of encoding. base64 is the default
     
     - returns: The json data
     */
    func serializeToJSON(
        outputFormatting: JSONEncoder.OutputFormatting = [],
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(.iso8601Full),
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64
    ) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = outputFormatting
        encoder.dateEncodingStrategy = dateEncodingStrategy
        encoder.dataEncodingStrategy = dataEncodingStrategy
        return try encoder.encode(self)
    }
    
    /**
     Convert this object to a json string
     
     - parameter outputFormatting: The formatting of the output JSON data (compact or pretty printed)
     - parameter dateEncodingStrategy: how do you want to format the date
     - parameter dataEncodingStrategy: what kind of encoding. base64 is the default
     
     - returns: The json string
     */
    func toJSON(
        outputFormatting: JSONEncoder.OutputFormatting = [],
        dateEncodingStrategy: JSONEncoder.DateEncodingStrategy = .formatted(.iso8601Full),
        dataEncodingStrategy: JSONEncoder.DataEncodingStrategy = .base64
    ) throws -> String? {
        let data = try serializeToJSON(outputFormatting: outputFormatting, dateEncodingStrategy: dateEncodingStrategy, dataEncodingStrategy: dataEncodingStrategy)
        return String(data: data, encoding: .utf8)
    }
    
    /**
     Converts this object to a dictionary
     */
    func toDictionary() -> [String: AnyObject] {
        return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: AnyObject] ?? [:]
    }
}

extension Decodable {
    /**
     Create an instance of this type from a json string
     
     - parameter data: The json data
     */
    init(jsonData: Data, dateFormatter: DateFormatter = .iso8601Full) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        self = try decoder.decode(Self.self, from: jsonData)
    }
    
    /**
     Initialize this object from an archived file from an URL
     
     - parameter fileNameInTemp: The filename
     */
    init(fileURL: URL, dateFormatter: DateFormatter) throws {
        let data = try Data(contentsOf: fileURL)
        try self.init(jsonData: data, dateFormatter: dateFormatter)
    }
}
