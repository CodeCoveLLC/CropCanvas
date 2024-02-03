//
//  UUID+Tokenized.swift
//
//
//  Created by Lukas Simonson on 2/3/24.
//

import Crypto
import Foundation

extension UUID {
    func tokenized() -> String {
        SHA512.hash(data: Data(uuidString.utf8)).hex
    }
}
