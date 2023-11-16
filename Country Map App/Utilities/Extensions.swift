//
//  Extensions.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-16.
//

import Foundation

/**
 Extension on Double to provide rounding functionality. (chatGPT)

 - Parameters:
   - places: The number of decimal places to round the Double value to.

 - Returns:
   The rounded Double value.

 - Note:
   This extension allows you to round a Double value to a specified number of decimal places.

 Example:
 ```swift
 let originalValue: Double = 3.14159
 let roundedValue = originalValue.rounded(toPlaces: 2)
 print(roundedValue) // Output: 3.14
 */

extension Double {
    func rounded(toPlaces places: Int ) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
