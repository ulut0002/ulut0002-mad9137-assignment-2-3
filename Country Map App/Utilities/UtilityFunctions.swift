//
//  UtilityFunctions.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-16.
//

import Foundation


/**
 Formats a given Double value into a String representation with decimal formatting. (chatGPT)

 - Parameters:
   - num: The Double value to be formatted.
   - fraction: The number of fractional digits to include in the formatted value (default is 0).

 - Returns:
   A String representation of the formatted number.

 - Note:
   The function uses `NumberFormatter` to achieve decimal formatting with a specified number of fractional digits. If the formatting operation fails, it defaults to returning "0".

 Example:
 ```swift
 let originalNumber: Double = 1234567.89
 let formattedNumber = formatNumber(num: originalNumber, fraction: 2)
 print(formattedNumber) // Output: "1,234,567.89"
 */
 
func formatNumber(num: Double, fraction: Int = 0) -> String {
  let numberFormatter = NumberFormatter()
  numberFormatter.numberStyle = .decimal
  numberFormatter.maximumFractionDigits = fraction
  let formattedValue = numberFormatter.string(from: num as NSNumber) ?? "0"
  return formattedValue
}




/**
 Compares two Country objects based on the specified sorting criteria.

 - Parameters:
   - country1: The first Country object to compare.
   - country2: The second Country object to compare.
   - sortBy: The sorting criteria specified by the `SORT_BY` enum.

 - Returns:
   A boolean value indicating whether `country1` should precede `country2` in the sorted order.

 - Note:
   The function takes two `Country` objects and a sorting criteria (`SORT_BY`). It performs a comparison based on the specified criteria and returns `true` if `country1` should come before `country2` in the sorted order; otherwise, it returns `false`.

 Example:
 ```swift
 let countryA = Country(name: "CountryA", population: 1000000, area: 5000, populationDensity: 200)
 let countryB = Country(name: "CountryB", population: 800000, area: 3000, populationDensity: 266)
 let ascendingComparison = compareCountries(countryA, countryB, .population_asc)
 print(ascendingComparison) // Output: true
 */

 func compareCountries(_ country1: Country,
                       _ country2: Country,
                       _ sortBy: SORT_BY) -> Bool{
    switch sortBy {
        case .alphabetically_asc:
            return country1.name < country2.name
        case .alphabetically_desc:
            return country1.name > country2.name
        case .population_asc:
            return country1.population ?? 0.0 < country2.population ?? 0.0
        case .population_desc:
            return country1.population ?? 0.0 > country2.population ?? 0.0
        case .area_asc:
            return country1.area ?? 0.0 < country2.area ?? 0.0
        case .area_desc:
            return country1.area ?? 0.0 > country2.area ?? 0.0
        case .density_asc:
            return country1.populationDensity < country2.populationDensity
        case .density_desc:
            return country1.populationDensity > country2.populationDensity
        }
}


