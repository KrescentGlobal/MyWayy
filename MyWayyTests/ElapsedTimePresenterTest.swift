//
//  ElapsedTimePresenterTest.swift
//  MyWayyTests
//
//  Created by Robert Hartman on 11/10/17.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import XCTest
@testable import MyWayy

class ElapsedTimePresenterTest: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testSecondsRemainder() {
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 0).secondsRemainder)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 60).secondsRemainder)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 3660).secondsRemainder)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 1).secondsRemainder)
        XCTAssertEqual(59, ElapsedTimePresenter(seconds: 59).secondsRemainder)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 61).secondsRemainder)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 3601).secondsRemainder)
    }

    func testWholeMinutesRemainder() {
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 0).wholeMinutesRemainder)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 1).wholeMinutesRemainder)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 59).wholeMinutesRemainder)
        XCTAssertEqual(59, ElapsedTimePresenter(seconds: 60 * 59 + 0).wholeMinutesRemainder)
        XCTAssertEqual(59, ElapsedTimePresenter(seconds: 60 * 59 + 59).wholeMinutesRemainder)

        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 60).wholeMinutesRemainder)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 61).wholeMinutesRemainder)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 3600 + 60).wholeMinutesRemainder)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 3600 + 119).wholeMinutesRemainder)
        XCTAssertEqual(2, ElapsedTimePresenter(seconds: 3600 + 120).wholeMinutesRemainder)
    }

    func testWholeHours() {
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 0).wholeHours)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 1).wholeHours)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 59).wholeHours)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 60 * 59).wholeHours)
        XCTAssertEqual(0, ElapsedTimePresenter(seconds: 60 * 59 + 59).wholeHours)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 3600).wholeHours)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 3601).wholeHours)
        XCTAssertEqual(1, ElapsedTimePresenter(seconds: 7200 - 1).wholeHours)
        XCTAssertEqual(2, ElapsedTimePresenter(seconds: 7200 + 0).wholeHours)
        XCTAssertEqual(2, ElapsedTimePresenter(seconds: 7200 + 1).wholeHours)
        XCTAssertEqual(2, ElapsedTimePresenter(seconds: 7200 + 3599).wholeHours)
        XCTAssertEqual(3, ElapsedTimePresenter(seconds: 7200 + 3600).wholeHours)
        XCTAssertEqual(3, ElapsedTimePresenter(seconds: 7200 + 3601).wholeHours)
    }

    func testHoursAndMinutesStringShort() {
        // Less than one hour
        XCTAssertEqual("0 min", ElapsedTimePresenter(seconds: 0).hoursAndMinutesStringShort)
        XCTAssertEqual("0 min 1 sec", ElapsedTimePresenter(seconds: 1).hoursAndMinutesStringShort)
        XCTAssertEqual("1 min 1 sec", ElapsedTimePresenter(seconds: 61).hoursAndMinutesStringShort)
        XCTAssertEqual("59 min", ElapsedTimePresenter(seconds: 3600 - 60).hoursAndMinutesStringShort)
        XCTAssertEqual("59 min 59 sec", ElapsedTimePresenter(seconds: 3600 - 1).hoursAndMinutesStringShort)

        // >= one hour
        XCTAssertEqual("1 hr", ElapsedTimePresenter(seconds: 3600).hoursAndMinutesStringShort)
        XCTAssertEqual("1 hr 1 min", ElapsedTimePresenter(seconds: 3600 + 1).hoursAndMinutesStringShort)

        XCTAssertEqual("2 hr", ElapsedTimePresenter(seconds: 7200).hoursAndMinutesStringShort)
        XCTAssertEqual("2 hr", ElapsedTimePresenter(seconds: 7200 - 1).hoursAndMinutesStringShort)
        XCTAssertEqual("2 hr 1 min", ElapsedTimePresenter(seconds: 7200 + 1).hoursAndMinutesStringShort)

        XCTAssertEqual("2 hr 1 min", ElapsedTimePresenter(seconds: 7200 + 59).hoursAndMinutesStringShort)
        XCTAssertEqual("2 hr 1 min", ElapsedTimePresenter(seconds: 7200 + 60).hoursAndMinutesStringShort)
        XCTAssertEqual("2 hr 2 min", ElapsedTimePresenter(seconds: 7200 + 61).hoursAndMinutesStringShort)
    }

    func testStopwatchStringShort() {
        // Less than one hour
        XCTAssertEqual("00:00", ElapsedTimePresenter(seconds: 0).stopwatchStringShort)
        XCTAssertEqual("00:01", ElapsedTimePresenter(seconds: 1).stopwatchStringShort)
        XCTAssertEqual("01:01", ElapsedTimePresenter(seconds: 61).stopwatchStringShort)
        XCTAssertEqual("59:00", ElapsedTimePresenter(seconds: 3600 - 60).stopwatchStringShort)
        XCTAssertEqual("59:59", ElapsedTimePresenter(seconds: 3600 - 1).stopwatchStringShort)

        // >= one hour
        XCTAssertEqual("01:00", ElapsedTimePresenter(seconds: 3600).stopwatchStringShort)
        XCTAssertEqual("01:01", ElapsedTimePresenter(seconds: 3600 + 1).stopwatchStringShort)

        XCTAssertEqual("02:00", ElapsedTimePresenter(seconds: 7200).stopwatchStringShort)
        XCTAssertEqual("02:00", ElapsedTimePresenter(seconds: 7200 - 1).stopwatchStringShort)
        XCTAssertEqual("02:01", ElapsedTimePresenter(seconds: 7200 + 1).stopwatchStringShort)

        XCTAssertEqual("02:01", ElapsedTimePresenter(seconds: 7200 + 59).stopwatchStringShort)
        XCTAssertEqual("02:01", ElapsedTimePresenter(seconds: 7200 + 60).stopwatchStringShort)
        XCTAssertEqual("02:02", ElapsedTimePresenter(seconds: 7200 + 61).stopwatchStringShort)
    }
}
