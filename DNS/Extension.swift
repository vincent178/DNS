//
//  Extension.swift
//  DNS
//
//  Created by Vincent Huang on 2020/6/20.
//  Copyright © 2020 Vincent Huang. All rights reserved.
//

import Foundation

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
