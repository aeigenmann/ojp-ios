//
//  OJPv2+LocationInformation.swift
//  LIR_ParserPOC
//
//  Created by Vasile Cotovanu on 12.03.2024.
//

import Foundation
import XMLCoder

public extension OJPv2 {
    struct LocationInformationDelivery: Codable, Sendable {
        public let responseTimestamp: String
        public let requestMessageRef: String?
        public let defaultLanguage: String?
        public let calcTime: Int?
        public let placeResults: [PlaceResult]

        public enum CodingKeys: String, CodingKey {
            case responseTimestamp = "siri:ResponseTimestamp"
            case requestMessageRef = "siri:RequestMessageRef"
            case defaultLanguage = "siri:DefaultLanguage"
            case calcTime = "CalcTime"
            case placeResults = "PlaceResult"
        }
    }

    struct PlaceResult: Codable, Sendable {
        public let place: Place
        public let complete: Bool
        public let probability: Float?

        public enum CodingKeys: String, CodingKey {
            case place = "Place"
            case complete = "Complete"
            case probability = "Probability"
        }
    }

    enum PlaceTypeChoice: Codable, Sendable, Hashable {
        case stopPoint(OJPv2.StopPoint)
        case stopPlace(OJPv2.StopPlace)
        case address(OJPv2.Address)
        case topographicPlace(OJPv2.TopographicPlace)

        enum CodingKeys: String, CodingKey {
            case stopPlace = "StopPlace"
            case address = "Address"
            case stopPoint = "StopPoint"
            case topographicPlace = "TopographicPlace"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            if container.contains(.stopPlace) {
                self = try .stopPlace(container.decode(StopPlace.self, forKey: .stopPlace))
            } else if container.contains(.stopPoint) {
                self = try .stopPoint(container.decode(StopPoint.self, forKey: .stopPoint))
            } else if container.contains(.topographicPlace) {
                self = try .topographicPlace(container.decode(TopographicPlace.self, forKey: .topographicPlace))
            } else if container.contains(.address) {
                self = try .address(container.decode(Address.self, forKey: .address))
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__PlaceStructure)
    struct Place: Codable, Sendable, Hashable {
        public let place: PlaceTypeChoice

        public let name: InternationalText
        public let geoPosition: GeoPosition
        public let modes: [Mode]

        public enum CodingKeys: String, CodingKey {
            case name = "Name"
            case geoPosition = "GeoPosition"
            case modes = "Mode"
        }

        public init(from decoder: any Decoder) throws {
            place = try PlaceTypeChoice(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            name = try container.decode(InternationalText.self, forKey: .name)
            geoPosition = try container.decode(GeoPosition.self, forKey: .geoPosition)
            modes = try container.decode([Mode].self, forKey: .modes)
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__TopographicPlaceStructure)
    struct TopographicPlace: Codable, Sendable, Hashable {
        public let topographicPlaceCode: String
        public let topographicPlaceName: InternationalText

        public enum CodingKeys: String, CodingKey {
            case topographicPlaceCode = "TopographicPlaceCode"
            case topographicPlaceName = "TopographicPlaceName"
        }
    }

    /// [Schema documentation on vdvde.github.io](https://vdvde.github.io/OJP/develop/documentation-tables/ojp.html#type_ojp__StopPointStructure)
    struct StopPoint: Codable, Sendable, Hashable {
        public let stopPointRef: String
        public let stopPointName: InternationalText
        public let parentRef: String?
        public let topographicPlaceRef: String?

        public enum CodingKeys: String, CodingKey {
            case stopPointRef = "siri:StopPointRef"
            case stopPointName = "StopPointName"
            case parentRef = "ParentRef"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }

    struct StopPlace: Codable, Sendable, Hashable {
        public let stopPlaceRef: String
        public let stopPlaceName: InternationalText
        public let privateCodes: [PrivateCode]
        public let topographicPlaceRef: String?

        public enum CodingKeys: String, CodingKey {
            case stopPlaceRef = "StopPlaceRef"
            case stopPlaceName = "StopPlaceName"
            case privateCodes = "PrivateCode"
            case topographicPlaceRef = "TopographicPlaceRef"
        }
    }

    struct Address: Codable, Sendable, Hashable {
        public let publicCode: String
        public let topographicPlaceRef: String?
        public let topographicPlaceName: String?
        public let countryName: String?
        public let postCode: String?
        public let name: InternationalText
        public let street: String?
        public let houseNumber: String?
        public let crossRoad: String?

        public enum CodingKeys: String, CodingKey {
            case publicCode = "PublicCode"
            case topographicPlaceName = "TopographicPlaceName"
            case topographicPlaceRef = "TopographicPlaceRef"
            case postCode = "PostCode"
            case name = "Name"
            case street = "Street"
            case houseNumber = "HouseNumber"
            case crossRoad = "CrossRoad"
            case countryName = "CountryName"
        }
    }

    struct PrivateCode: Codable, Sendable, Hashable {
        public let system: String
        public let value: String

        public enum CodingKeys: String, CodingKey {
            case system = "System"
            case value = "Value"
        }
    }

    enum LocationInformationInputTypeChoice: Codable, Sendable {
        case initialInput(InitialInput)
        case placeRef(PlaceRefChoice)

        public enum CodingKeys: String, CodingKey {
            case initialInput = "InitialInput"
            case placeRef = "PlaceRef"
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if container.contains(.initialInput) {
                let initial = try container.decode(InitialInput.self, forKey: .initialInput)
                self = .initialInput(initial)
            } else if container.contains(.placeRef) {
                let placeRef = try PlaceRefChoice(from: decoder)
                self = .placeRef(placeRef)
            } else {
                throw OJPSDKError.notImplemented()
            }
        }
    }

    struct LocationInformationRequest: Codable, Sendable {
        public let requestTimestamp: Date
        public let input: LocationInformationInputTypeChoice
        public let restrictions: PlaceParam

        public enum CodingKeys: String, CodingKey {
            case requestTimestamp = "siri:RequestTimestamp"
            case restrictions = "Restrictions"

            case initialInput = "InitialInput"
            case placeRef = "PlaceRef"
        }

        public init(requestTimestamp: Date, input: LocationInformationInputTypeChoice, restrictions: PlaceParam) {
            self.requestTimestamp = requestTimestamp
            self.input = input
            self.restrictions = restrictions
        }

        public init(from decoder: any Decoder) throws {
            input = try LocationInformationInputTypeChoice(from: decoder)
            let container = try decoder.container(keyedBy: CodingKeys.self)
            requestTimestamp = try container.decode(Date.self, forKey: .requestTimestamp)
            restrictions = try container.decode(PlaceParam.self, forKey: .restrictions)
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: OJPv2.LocationInformationRequest.CodingKeys.self)
            try container.encode(requestTimestamp, forKey: OJPv2.LocationInformationRequest.CodingKeys.requestTimestamp)
            switch input {
            case let .initialInput(initialInput):
                try container.encode(initialInput, forKey: .initialInput)
            case let .placeRef(placeRefChoice):
                try container.encode(placeRefChoice, forKey: .placeRef)
            }
            // Order of encoded elements is enforced by service. would fail otherwise
            try container.encode(restrictions, forKey: OJPv2.LocationInformationRequest.CodingKeys.restrictions)
        }
    }

    struct InitialInput: Codable, Sendable {
        public let geoRestriction: GeoRestriction?
        public let name: String?

        public enum CodingKeys: String, CodingKey {
            case geoRestriction = "GeoRestriction"
            case name = "Name"
        }
    }

    struct GeoRestriction: Codable, Sendable {
        public let rectangle: Rectangle?

        public enum CodingKeys: String, CodingKey {
            case rectangle = "Rectangle"
        }
    }

    struct Rectangle: Codable, Sendable {
        public let upperLeft: GeoPosition
        public let lowerRight: GeoPosition

        public enum CodingKeys: String, CodingKey {
            case upperLeft = "UpperLeft"
            case lowerRight = "LowerRight"
        }
    }

    struct PlaceParam: Codable, Sendable {
        public init(type: [PlaceType], numberOfResults: Int = 10, includePtModes: Bool = true) {
            self.type = type
            self.numberOfResults = numberOfResults
            self.includePtModes = includePtModes
        }

        public let type: [PlaceType]
        public let numberOfResults: Int
        let includePtModes: Bool

        public enum CodingKeys: String, CodingKey {
            case type = "Type"
            case numberOfResults = "NumberOfResults"
            case includePtModes = "IncludePtModes"
        }
    }
}

extension OJPv2.PlaceTypeChoice: Identifiable {
    public var id: String {
        switch self {
        case let .stopPoint(stopPoint):
            stopPoint.stopPointRef
        case let .stopPlace(stopPlace):
            stopPlace.stopPlaceRef
        case let .address(address):
            address.publicCode
        case let .topographicPlace(topographicPlace):
            topographicPlace.topographicPlaceCode
        }
    }
}

extension OJPv2.PlaceResult: Identifiable {
    public var id: String { place.place.id }
}
