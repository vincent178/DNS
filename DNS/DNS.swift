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
    case notComplete
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
    
    public func query(domain: String, queue: DispatchQueue, completion: @escaping (DNSRR?, Error?) -> Void) {
        func doQuery() -> Void {
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
                    completion(nil, DNSServiceError.notComplete)
                    return
                }
                
                let rr = DNSRR.deserialize(data: [UInt8](data!))
                completion(rr, nil)
            }
        }
        
        if self.connection.state != .ready {
            self.connection.stateUpdateHandler = nil
            self.connection.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    self.state = .ready
                    doQuery()
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
            self.connection.start(queue: queue)
            return
        }
        
        doQuery()
    }
    
    public func stop() {
        self.connection.stateUpdateHandler = nil
        self.connection.cancel()
    }
}
