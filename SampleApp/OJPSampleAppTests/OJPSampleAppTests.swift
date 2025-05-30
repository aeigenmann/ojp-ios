//
//  OJPSampleAppTests.swift
//  OJPSampleAppTests
//
//  Created by Lehnherr Reto on 03.04.2024.
//

import OJP
@testable import OJPSampleApp
import XCTest

final class OJPSampleAppTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testMinimalTRR_Bern_Brig_StMoritz() async throws {
        _ = OJPHelper(environment: .int)
        let ojp = OJPHelper.ojp
        let trips = try await ojp.requestTrips(
            from: .stopPlaceRef(
                .init(stopPlaceRef: "8507000", name: .init("Bern"))),
            to: .stopPlaceRef(.init(stopPlaceRef: "8509253", name: .init("St. Moritz"))),
            via: [.stopPlaceRef(.init(stopPlaceRef: "8501609", name: .init("Brig")))],
            params: .init(
                includeIntermediateStops: true,
                includeAllRestrictedLines: true,
                useRealtimeData: .explanatory
            )
        )
        XCTAssertTrue(trips.tripResults.count > 0)
        let tripResult = try XCTUnwrap(trips.tripResults.first)

        // assert triprefinement with full request
        let refinedTripFromFullTripResult = try await ojp.requestTripRefinement(tripResult: tripResult, useMinimalRequest: false)
        _ = try XCTUnwrap(refinedTripFromFullTripResult.tripResults.first)

        // assert triprefinement with minimal request
        let refinedTripFromMinmalTripResult = try await ojp.requestTripRefinement(tripResult: tripResult)
        _ = try XCTUnwrap(refinedTripFromMinmalTripResult.tripResults.first)
    }

    @MainActor
    func testMinimalTRR_KoenizGeoPosition_Brig() async throws {
        // CURRENTLY FAILING. Reported issue here: https://github.com/openTdataCH/ojp-sdk/issues/227#issuecomment-2778012964
        _ = OJPHelper(environment: .test)

        let ojp = OJPHelper.ojp
        let trips = try await ojp.requestTrips(
            from: .geoPosition(.init(geoPosition: .init(longitude: 7.416315, latitude: 46.926739), name: .init("Köniz"))),
            to: .stopPlaceRef(.init(stopPlaceRef: "8503000", name: .init("Zürich"))),
            params: .init(
                includeIntermediateStops: true,
                includeAllRestrictedLines: true,
                useRealtimeData: .explanatory
            )
        )
        XCTAssertTrue(trips.tripResults.count > 0)
        let tripResult = try XCTUnwrap(trips.tripResults.first)

        // assert triprefinement with full request
        let refinedTripFromFullTripResult = try await ojp.requestTripRefinement(tripResult: tripResult, useMinimalRequest: false)
        _ = try XCTUnwrap(refinedTripFromFullTripResult.tripResults.first)

        // assert triprefinement with minimal request
        let refinedTripFromMinmalTripResult = try await ojp.requestTripRefinement(tripResult: tripResult)
        _ = try XCTUnwrap(refinedTripFromMinmalTripResult.tripResults.first)
    }
}
