//
//  Constants.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-16.
//

import Foundation
import SwiftUI


/**
 A struct containing constants used throughout the application.
 */
struct CONSTANTS {
    /// The key used to store and retrieve favorite items in UserDefaults.
    static let FAVORITES_KEY = "Favorites"
  
    static let SHEET_GRADIENT_COLOR_1 = Color(red: 228/255, green: 229/255, blue: 230/255).opacity(0.5)
    static let SHEET_GRADIENT_COLOR_2 = Color(red: 0/255, green: 65/255, blue: 106/255).opacity(0.2)
    static let SHEET_TITLE_COLOR = Color(red: 245/255, green: 245/255, blue: 245/255)
    static let EXCLUDED_REGIONS:[String] = ["Polar","Antarctic Ocean","Antarctic"]
    
    static let DATA_URL = "https://raw.githubusercontent.com/shah0150/data/main/countries_data.json"
    
}


enum IMAGE_NAMES {
    static let CLOSE_SHEET = "chevron.down"
    static let MENU = "ellipsis"
    static let CLEAR_TEXT = "xmark.circle.fill"
    static let SORT = "arrow.up.arrow.down"
    static let FAVORITED = "star.fill"
    static let NOT_FAVORITED = "star"
    static let FETCH_ERROR_VIEW = "flag.slash"
}


/**
 Enum representing different states of data fetching.
 */
enum FETCH_STATUS {
    /// Indicates that data is currently being loaded.
    case loading
    
    /// Indicates that an error occurred during data fetching.
    case error
    
    /// Indicates that data fetching is in an idle state.
    case idle
}


/**
 Enum representing different grouping options.
 */
enum GROUP_BY {
    /// Indicates no grouping.
    case none
    
    /// Group items by area.
    case area
}


/**
 Enum representing different sorting criteria.
 */
enum SORT_BY {
    /// Sort alphabetically in ascending order.
    case alphabetically_asc
      
    /// Sort alphabetically in descending order.
    case alphabetically_desc
      
    /// Sort by population in ascending order.
    case population_asc
      
    /// Sort by population in descending order.
    case population_desc
      
    /// Sort by area in ascending order.
    case area_asc
      
    /// Sort by area in descending order.
    case area_desc
      
    /// Sort by population density in ascending order.
    case density_asc
  
    /// Sort by population density in descending order.
    case density_desc
}






/**
 Represents the data structure for country-related information.

 - Parameters:
   - status: The current fetch status of the country data, indicating whether it's loading, in an error state, or idle.
   - countries: An array of `Country` objects containing detailed information about each country.

 - Note:
   This struct encapsulates the status of fetching country data and the associated array of `Country` objects. The `status` property provides information about the state of the data, such as loading, error, or idle. The `countries` property holds an array of `Country` instances with detailed information for each country.

 Example:
 ```swift
 var countryData = CountryData(status: .loading, countries: [])
 print(countryData.status) // Output: loading

 */
struct CountryData {
  var status: FETCH_STATUS
  var countries: [Country]
}







/**
 Represents data for a single data point in a chart.

 - Parameters:
   - type: The type or category of the data point.
   - value: The numerical value associated with the data point.

 - Note:
   This struct is used to encapsulate information for individual data points in a chart. The `type` property represents the category or type of the data point, and the `value` property holds the numerical value associated with it.

 Example:
 ```swift
 let chartDataPoint = ChartData(type: "Sales", value: 1200.0)
 print(chartDataPoint.value) // Output: 1200.0
 */
struct ChartData: Identifiable, Equatable {
    let type: String
    var value: Double
    
    var id: String {
        return type
    }
}



