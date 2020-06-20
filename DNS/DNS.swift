//
//  DNS.swift
//  DNS
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//

import Foundation
import Network

public class DNSService {
    private let connection: NWConnection
    
    public typealias Handler = (Result<[String], Error>) -> Void
    
    public init(nsserver: NWEndpoint.Host?, port: NWEndpoint.Port?) {
        self.connection = NWConnection(host: nsserver ?? "8.8.8.8", port: port ?? 53, using: .udp)
    }
    
    public func query(domain: String, completionHandler: @escaping Handler) {
        if self.connection.stateUpdateHandler == nil {
            self.connection.stateUpdateHandler = { (newState) in
                switch (newState) {
                case .ready:
                    // TODO: replace with logger
                    print("ready")
                    
                    let q: DNSQuestion = DNSQuestion(Domain: domain, Typ: 0x1, Class: 0x1)
                    let query: DNSRR = DNSRR(ID: 0xAAAA, RD: true, Questions: [q], Answers: [])
                    
                    self.connection.send(content: query.serialize(), completion: NWConnection.SendCompletion.contentProcessed(({ (NWError) in
                        print(NWError!)
                    })))
                    self.connection.receiveMessage { (data, context, isComplete, error) in
                        if error != nil {
                            print("ERROR: ", error!.localizedDescription)
                            return
                        }
                        
                        if !isComplete {
                            print("isComplete false not support yet")
                            return
                        }
                        
                        let responseCode = data![3] & 0xF
                        
                        if responseCode != 0 {
                            print("DNS ERROR")
                            return
                        }
                        
                        DNSRR.deserialize(data: [UInt8](data!))
                    }
                   
                case .setup:
                    print("setup")
                case .cancelled:
                    print("cancelled")
                case .preparing:
                    print("Preparing")
                default:
                    print("waiting or failed")
                }
            }
            self.connection.start(queue: .global())
        }
    }
}
