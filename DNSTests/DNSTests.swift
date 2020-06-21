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
    
    func testDNSServiceQuery() {
        let exp = expectation(description: "query dns")

        let ds = DNSService.init()
        ds.start()
        sleep(1)
        ds.query(domain: "vincent178.site", completion: { (rr, err) in
            ds.stop()
            
            XCTAssertNil(err)
            XCTAssertNotNil(rr)
            
            XCTAssertEqual(rr!.Questions[0].Domain, "vincent178.site")
            XCTAssertEqual(rr!.ANCount, 3)
            XCTAssertEqual(rr!.Answers.map { $0.RData }.sorted(), ["104.28.23.47", "172.67.130.241", "104.28.22.47"].sorted())
            
            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3, handler: { error in
            if error != nil {
                XCTFail("waitForExpectations error \(error.debugDescription)")
            }
        })
    }
    
    func testCustomNameServer() {
        let exp = expectation(description: "query dns")

        let ds = DNSService.init(nsserver: "ns-926.awsdns-51.net")
        ds.start()
        sleep(1)
        ds.query(domain: "api.disco.goateng.com", completion: { (rr, err) in
            ds.stop()
            
            XCTAssertNil(err)
            XCTAssertNotNil(rr)

            XCTAssertEqual(rr!.Questions[0].Domain, "api.disco.goateng.com")
            XCTAssertEqual(rr!.ANCount, 1)
            XCTAssertTrue(["www.goat.com", "www.goatchina.cn"].contains(rr!.Answers[0].RData))

            exp.fulfill()
        })
        
        waitForExpectations(timeout: 3, handler: { error in
            if error != nil {
                XCTFail("waitForExpectations error \(error.debugDescription)")
            }
        })
    }
}
