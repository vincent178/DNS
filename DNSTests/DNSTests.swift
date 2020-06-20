//
//  DNSTests.swift
//  DNSTests
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//

import XCTest
import DNS

class DNSTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testDeserialize() {
        let data: [UInt8] = [170, 170,133,0, 0, 1, 0, 1, 0, 4, 0, 0, 3,97,112,105,5,100,105,115,99,111,7,103,111,97,116,101,110,103,3,99,111,109,0,0,1,0,1,192,12,0,5,0,1,0,0,1,44,0,11,3,119,119,119,4,103,111,97,116,192,30,192,16,0,2,0,1,0,2,163,0,0,23,7,110,115,45,49,50,56,55,9,97,119,115,100,110,115,45,51,50,3,111,114,103,0,192,16,0,2,0,1,0,2,163,0,0,25,7,110,115,45,49,54,51,52,9,97,119,115,100,110,115,45,49,50,2,99,111,2,117,107,0,192,16,0,2,0,1,0,2,163,0,0,19,6,110,115,45,52,56,52,9,97,119,115,100,110,115,45,54,48,192,30,192,16,0,2,0,1,0,2,163,0,0,22,6,110,115,45,57,50,54,9,97,119,115,100,110,115,45,53,49,3,110,101,116,0]
        let rr = DNSRR.deserialize(data: data)
        print(rr)
        
    }
    
    func testDeserializeName() {
        let data: [UInt8] = [170, 170,133,0, 0, 1, 0, 1, 0, 4, 0, 0, 3,97,112,105,5,100,105,115,99,111,7,103,111,97,116,101,110,103,3,99,111,109,0,0,1,0,1,192,12,0,5,0,1,0,0,1,44,0,11,3,119,119,119,4,103,111,97,116,192,30,192,16,0,2,0,1,0,2,163,0,0,23,7,110,115,45,49,50,56,55,9,97,119,115,100,110,115,45,51,50,3,111,114,103,0,192,16,0,2,0,1,0,2,163,0,0,25,7,110,115,45,49,54,51,52,9,97,119,115,100,110,115,45,49,50,2,99,111,2,117,107,0,192,16,0,2,0,1,0,2,163,0,0,19,6,110,115,45,52,56,52,9,97,119,115,100,110,115,45,54,48,192,30,192,16,0,2,0,1,0,2,163,0,0,22,6,110,115,45,57,50,54,9,97,119,115,100,110,115,45,53,49,3,110,101,116,0]
        var (name, len) = DNSRR.deserializeName(data: data, startAt: 12)
        XCTAssertEqual(name, "api.disco.goateng.com")
        XCTAssertEqual(len, 23)
        
        (name, len) = DNSRR.deserializeName(data: data, startAt: 51)
        XCTAssertEqual(name, "www.goat.com")
        XCTAssertEqual(len, 11)
    }
}
