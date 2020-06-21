//
//  DNS.swift
//  DNS
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//

import Foundation
import Network

enum DNSServiceError: Error {
    case connectionNotReady
}

// https://developer.apple.com/documentation/network
@available(macOS 10.14, *)
@available(iOS 12, *)
public class DNSService {
    private let connection: NWConnection
    private var state: NWConnection.State
        
    public init(host: NWEndpoint.Host = "8.8.8.8", port: NWEndpoint.Port = 53) {
        self.connection = NWConnection(host: host, port: port, using: .udp)
        self.state = .cancelled
    }
    
    public func start() {
        self.connection.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                self.state = .ready
            case .cancelled:
                self.state = .cancelled
            case .setup:
                self.state = .setup
            case .preparing:
                self.state = .preparing
            default:
                print("waiting")
            }
        }
        self.connection.start(queue: .global())
    }
    
    public func query(domain: String, completion: @escaping (DNSRR?, Error?) -> Void) {
        if self.state != .ready {
            completion(nil, DNSServiceError.connectionNotReady)
        }
        
        let q: DNSQuestion = DNSQuestion(Domain: domain, Typ: 0x1, Class: 0x1)
        let query: DNSRR = DNSRR(ID: 0xAAAA, RD: true, Questions: [q])
        
        self.connection.send(content: query.serialize(), completion: NWConnection.SendCompletion.contentProcessed { error in
            if error != nil {
                completion(nil, error)
            }
        })
        
        self.connection.receiveMessage { (data, context, isComplete, error) in
            if error != nil {
                completion(nil, error)
                return
            }
            
            if !isComplete {
                print("isComplete \(isComplete) not support yet")
                return
            }
            
            let responseCode = data![3] & 0xF
            
            if responseCode != 0 {
                print("DNS QUERY ERROR")
                return
            }
            
            let rr = DNSRR.deserialize(data: [UInt8](data!))
            completion(rr, nil)
        }
    }
    
    public func stop() {
        self.connection.stateUpdateHandler = nil
        self.connection.cancel()
    }
}
