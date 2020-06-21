//
//  RR.swift
//  DNS
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//

import Foundation

// https://www.ietf.org/rfc/rfc1035.txt 4.1.1. Header section format
public struct DNSRR {
    var ID: UInt16
    var QR: Bool = false
    var Opcode: UInt8 = 0x0
    
    var AA: Bool = false
    var TC: Bool = false
    var RD: Bool = false
    var RA: Bool = false
    var Z: UInt8 = 0x0
    var ResponseCode: UInt8 = 0x0
    
    public var QDCount: UInt16 = 0x0
    public var ANCount: UInt16 = 0x0
    var NSCount: UInt16 = 0x0
    var ARCount: UInt16 = 0x0
    
    public var Questions: [DNSQuestion] = []
    public var Answers: [DNSResource] = []
    
    public func serialize() -> [UInt8] {
        var bytes: [UInt8] = []
        
        let qd = UInt16(self.Questions.count)
        
        bytes.append(contentsOf: self.ID.toUInt8())
        
        // |QR|   Opcode  |AA|TC|RD|
        let qr = UInt8(self.QR.toUInt8() << 7)
        let op = UInt8(self.Opcode << 3)
        let aa = UInt8(self.AA.toUInt8() << 2)
        let tc = UInt8(self.TC.toUInt8() << 1)
        let rd = UInt8(self.RD.toUInt8())
        bytes.append(qr | op | aa | tc | rd)
        
        // |RA|   Z    |   RCODE   |
        let ra = UInt8(self.RA.toUInt8() << 7)
        let z = self.Z << 4
        bytes.append(ra | z | self.ResponseCode)
        
        bytes.append(contentsOf: qd.toUInt8())
        bytes.append(contentsOf: self.ANCount.toUInt8())
        bytes.append(contentsOf: self.NSCount.toUInt8())
        bytes.append(contentsOf: self.ARCount.toUInt8())
        
        _ = self.Questions.map { bytes.append(contentsOf: $0.serialize()) }
        
        return bytes
    }
    
    public static func deserialize(data: [UInt8]) -> DNSRR {
        let id = UInt16(data[0] << 8) + UInt16(data[1])
        let qr = data[2] >> 7 == 1
        let opcode = data[2] & 0x78 >> 3
        let aa = data[2] & 0x04 >> 2 == 1
        let tc = data[2] & 0x02 >> 1 == 1
        let rd = data[2] & 0x01 == 1
        let ra = data[3] >> 7 == 1
        let z = data[3] & 0x70 >> 4
        let responseCode = data[3] & 0x0F
        
        if responseCode != 0 {
            return DNSRR(ID: id,
                         QR: qr,
                         Opcode: opcode,
                         AA: aa,
                         TC: tc,
                         RD: rd,
                         RA: ra,
                         Z: z,
                         ResponseCode: responseCode)
        }
        
        let qdCount = UInt16(data[4]) << 8 + UInt16(data[5])
        let anCount = UInt16(data[6]) << 8 + UInt16(data[7])
        let nsCount = UInt16(data[8]) << 8 + UInt16(data[9])
        let arCount = UInt16(data[10]) << 8 + UInt16(data[11])
        
        var pos = 12
        
        // questions
        var i = qdCount
        var questions: [DNSQuestion] = []
        while i > 0 {
            let (name, offset) = deserializeName(data: data, startAt: pos)
            let qtype = UInt16(data[pos+offset]) << 8 + UInt16(data[pos+offset+1])
            let qclass = UInt16(data[pos+offset+2]) << 8 + UInt16(data[pos+offset+3])
            questions.append(DNSQuestion(Domain: name, Typ: qtype, Class: qclass))
            pos = pos + offset + 4
            i -= 1
        }
        
        // answers
        var answers: [DNSResource] = []
        i = anCount
        while i > 0 {
            var (name, offset) = deserializeName(data: data, startAt: pos)
            let typ = UInt16(data[pos+offset]) << 8 + UInt16(data[pos+offset+1])
            let cls = UInt16(data[pos+offset+2]) << 8 + UInt16(data[pos+offset+3])
            let ttl = UInt32(data[pos+offset+4]) << 24 + UInt32(data[pos+offset+5]) << 16 + UInt32(data[pos+offset+6]) << 8 + UInt32(data[pos+offset+7])
            let rlen = UInt16(data[pos+offset+8]) << 8 + UInt16(data[pos+offset+9])
            
            pos = pos + offset + 10
            var domain = ""
            if typ == 1 && rlen == 4 {
                domain = data[pos...pos+3].map{ String($0) }.joined(separator: ".")
                pos += 4
            } else if typ == 5 {
                (domain, offset) = deserializeName(data: data, startAt: pos)
                pos += offset
            } else {
                print("TYPE \(typ) DOES NOT SUPPORT YET")
                break
            }
            
            let answer = DNSResource(Domain: name, Typ: typ, Class: cls, TTL: ttl, RDLength: rlen, RData: domain)
            answers.append(answer)
            i -= 1
        }
        
        return DNSRR(ID: id,
                     QR: qr,
                     Opcode: opcode,
                     AA: aa,
                     TC: tc,
                     RD: rd,
                     RA: ra,
                     Z: z,
                     ResponseCode: responseCode,
                     QDCount: qdCount,
                     ANCount: anCount,
                     NSCount: nsCount,
                     ARCount: arCount,
                     Questions: questions,
                     Answers: answers)
    }

    private static func deserializeName(data: [UInt8], startAt: Int) -> (String, Int) {
        var ss: [String] = []
        var i = startAt
        while true {
            if data[i] == 0x0 {
                i += 1
                break
            }
            
            // pointer to name
            if data[i] & 0xC0 == 0xC0 {
                let (s, _) = deserializeName(data: data, startAt: Int(data[i] & 0x3F << 8)  + Int(data[i+1]))
                i += 2
                ss.append(s)
                break
            }
            
            let l = Int(data[i])
            let s = String.init(bytes: data[i+1...i+l], encoding: .ascii)
            ss.append(s!)
            i = i + l + 1
        }
        return (ss.joined(separator: "."), i-startAt)
    }
}

// https://www.ietf.org/rfc/rfc1035.txt 4.1.2. Question section format
public struct DNSQuestion {
    public var Domain: String
    public var Typ: UInt16
    public var Class: UInt16
    
    func serialize() -> [UInt8] {
        var bytes: [UInt8] = []
        
        _ = self.Domain.split(separator: ".").map {
            let length = $0.count
            bytes.append(UInt8(length))
            bytes.append(contentsOf: Array($0.utf8))
        }
        
        bytes.append(0x0)
        
        bytes.append(contentsOf: self.Typ.toUInt8())
        bytes.append(contentsOf: self.Class.toUInt8())
        
        return bytes
    }
}

public struct DNSResource {
    public var Domain: String
    public var Typ: UInt16
    public var Class: UInt16
    public var TTL: UInt32
    public var RDLength: UInt16
    public var RData: String
}
