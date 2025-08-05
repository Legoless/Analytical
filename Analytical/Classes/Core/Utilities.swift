//
//  Utilities.swift
//  Analytical
//
//  Created by Vid Vozelj on 5. 8. 25.
//

package func randomId(_ length: Int = 64) -> String {
    let characters = Array("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    
    let result = (0..<length).compactMap { _ in characters.randomElement() }
    
    return String(result)
}
