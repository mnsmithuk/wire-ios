//
// Wire
// Copyright (C) 2024 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

import Foundation

// MARK: JSON Decoder / Encoder

extension JSONDecoder {

    public static var defaultDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let rawDate = try container.decode(String.self)

            guard let date = Date(transportString: rawDate) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Expected date string to be ISO8601-formatted with fractional seconds"
                )
            }

            return date as Date
        }

        return decoder
    }

    func setAPIVersion(_ apiVersion: APIVersion) {
        userInfo[.apiVersion] = apiVersion
    }
}

extension JSONEncoder {

    static var defaultEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom({ date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(date.transportString())
        })

        return encoder
    }

    func setAPIVersion(_ apiVersion: APIVersion) {
        userInfo[.apiVersion] = apiVersion
    }
}

// MARK: Decodable / Encodable

extension Decodable {

    /// Initialize object from JSON Data or log an error if fails
    ///
    /// - parameter payloadData: JSON data as raw bytes

    init?(_ payloadData: Data, decoder: JSONDecoder = .defaultDecoder) {
        do {
            self = try decoder.decode(Self.self, from: payloadData)
        } catch let error {
            WireLogger.network.warn("Failed to decode \(Self.self) from payload: \(error)")
            return nil
        }
    }

    /// Initialize object from JSON Data for a specific api version or log an error if it fails
    ///
    /// - parameters:
    ///    - payloadData: JSON data as raw bytes
    ///    - apiVersion: API version to decode for
    ///    - decoder: JSONDecoder to use

    init?(_ payloadData: Data, apiVersion: APIVersion, decoder: JSONDecoder = .defaultDecoder) {
        decoder.setAPIVersion(apiVersion)
        self.init(payloadData, decoder: decoder)
    }

    /// Initialize object from a transport response
    ///
    /// - parameter response: ZMTransportResponse with a JSON payload

    init?(_ response: ZMTransportResponse, decoder: JSONDecoder = .defaultDecoder) {
        guard let rawData = response.rawData else {
            return nil
        }

        self.init(rawData, decoder: decoder)
    }

}

extension Encodable {

    /// Encode object to binary payload and log an error if it fails
    ///
    /// - Parameters:
    ///   - apiVersion: the api version to encode the payload for
    ///   - encoder: JSONEncoder to use

    func payloadData(apiVersion: APIVersion? = nil, encoder: JSONEncoder = .defaultEncoder) -> Data? {
        if let apiVersion {
            encoder.setAPIVersion(apiVersion)
        }

        do {
            return try encoder.encode(self)
        } catch {
            Logging.network.warn("Failed to encode payload: \(error)")
            return nil
        }
    }

    /// Encode object to string payload and log an error if it fails.
    ///
    /// - Parameters:
    ///   - apiVersion: the api version to encode the payload for
    ///   - encoder: JSONEncoder to use

    func payloadString(apiVersion: APIVersion? = nil, encoder: JSONEncoder = .defaultEncoder) -> String? {
        return payloadData(apiVersion: apiVersion, encoder: encoder).flatMap {
            String(decoding: $0, as: UTF8.self)
        }
    }

    func encodeToJSONString(encoder: JSONEncoder = .defaultEncoder) throws -> String {
        let data = try encodeToJSON(encoder: encoder)
        let string = String(decoding: data, as: UTF8.self)
        return string
    }

    func encodeToJSON(encoder: JSONEncoder = .defaultEncoder) throws -> Data {
        do {
            return try encoder.encode(self)
        } catch {
            throw JSONEncodingFailure.failedToEncode(error)
        }
    }

}

enum JSONEncodingFailure: Error {

    case failedToEncode(Error)

}

// MARK: API version aware coding

protocol DecodableAPIVersionAware: Decodable {
    init(from decoder: Decoder, apiVersion: APIVersion) throws
}

protocol EncodableAPIVersionAware: Encodable {
    func encode(to encoder: Encoder, apiVersion: APIVersion) throws
}

protocol CodableAPIVersionAware: EncodableAPIVersionAware & DecodableAPIVersionAware {}

extension DecodableAPIVersionAware {

    init(from decoder: Decoder) throws {
        guard let apiVersion = decoder.apiVersion ?? BackendInfo.apiVersion else {
            throw APIVersionAwareCodingError.missingAPIVersion
        }

        try self.init(from: decoder, apiVersion: apiVersion)
    }

}

extension EncodableAPIVersionAware {

    func encode(to encoder: Encoder) throws {
        guard let apiVersion = encoder.apiVersion ?? BackendInfo.apiVersion else {
            throw APIVersionAwareCodingError.missingAPIVersion
        }

        try encode(to: encoder, apiVersion: apiVersion)
    }

}

// MARK: - Helpers

enum APIVersionAwareCodingError: Error {
    case missingAPIVersion
}

private extension CodingUserInfoKey {
    static var apiVersion: Self = .init(rawValue: "APIVersionKey")!
}

extension Decoder {
    var apiVersion: APIVersion? {
        return userInfo[.apiVersion] as? APIVersion
    }
}

extension Encoder {
    var apiVersion: APIVersion? {
        return userInfo[.apiVersion] as? APIVersion
    }
}
