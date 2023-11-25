import Foundation

enum NetworkError: Error {
    case non200StatusCode(statusCode: Int, data: Data?)
    case invalidResponseFormat
    case decoding(error: Error)
    case decodingString
    case noDataInResponse
}
