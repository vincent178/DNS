//
//  DNS.swift
//  DNS
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//

import Foundation
import Network

extension UInt16 {
    func toUInt8() -> [UInt8] {
        return [UInt8(self >> 8), UInt8(self & 0xff)]
    }
}

extension Bool {
    func toUInt8() -> UInt8 {
        return self ? 0x01 : 0x00
    }
}

// https://www.ietf.org/rfc/rfc1035.txt 4.1.1. Header section format
struct DNSQuery {
    var ID: UInt16
    var QR: Bool = false
    var Opcode: UInt8 = 0x0
    
    var AA: Bool = false
    var TC: Bool = false
    var RD: Bool = false
    var RA: Bool = false
    var Z: UInt8 = 0x0
    var ResponseCode: UInt8 = 0x0
    
    var QDCount: UInt16 = 0x0000
    var ANCount: UInt16 = 0x0000
    var NSCount: UInt16 = 0x0000
    var ARCount: UInt16 = 0x0000
    
    var Questions: Array<DNSQuestion>
    
    func encode() -> [UInt8] {
        var bytes: [UInt8] = []
        
        let qd = UInt16(self.Questions.count)
        
        bytes.append(contentsOf: self.ID.toUInt8())
        
        // QR|   Opcode  |AA|TC|RD
        let qr = UInt8(self.QR.toUInt8() << 7)
        let op = UInt8(self.Opcode << 3)
        let aa = UInt8(self.AA.toUInt8() << 2)
        let tc = UInt8(self.TC.toUInt8() << 1)
        let rd = UInt8(self.RD.toUInt8())
        bytes.append(qr | op | aa | tc | rd)
        
        // RA|   Z    |   RCODE
        let ra = UInt8(self.RA.toUInt8() << 7)
        let z = self.Z << 4
        bytes.append(ra | z | self.ResponseCode)
        
        bytes.append(contentsOf: qd.toUInt8())
        bytes.append(contentsOf: self.ANCount.toUInt8())
        bytes.append(contentsOf: self.NSCount.toUInt8())
        bytes.append(contentsOf: self.ARCount.toUInt8())
        
        _ = self.Questions.map { bytes.append(contentsOf: $0.encode()) }
        
        return bytes
    }
}

// https://www.ietf.org/rfc/rfc1035.txt 4.1.2. Question section format
struct DNSQuestion {
    var Domain: String
    var Typ: UInt16
    var Class: UInt16
    
    func encode() -> [UInt8] {
        var bytes: [UInt8] = []
        
        _ = self.Domain.split(separator: ".").map {
            let length = $0.count
            bytes.append(UInt8(length))
            bytes.append(contentsOf: Array($0.utf8))
        }
        
        bytes.append(0)
        
        print("domain length: ", bytes.count)
        
        print("domain: ", bytes)
        
        bytes.append(contentsOf: self.Typ.toUInt8())
        bytes.append(contentsOf: self.Class.toUInt8())
        
        return bytes
    }
}

struct DNSResource {
    var Domain: String // dynamic length
    var Typ: UInt16
    var Class: UInt16
    var TTL: UInt32
    var RDLength: UInt16
    var RData: String
}

