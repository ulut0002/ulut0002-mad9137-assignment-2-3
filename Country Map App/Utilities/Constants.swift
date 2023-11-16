//
//  Constants.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-16.
//

import Foundation

/**
 A struct containing constants used throughout the application.
 */
struct Constants {
    /// The key used to store and retrieve favorite items in UserDefaults.
    static let FAVORITES_KEY = "Favorites"
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
 Enum representing different sorting criteria.
 */
enum SORT_BY {
    /// Sort alphabetically in ascending order.
    case alphabetically_asc
      
    /// Sort alphabetically in descending order.
    case alphabetically_dec
      
    /// Sort by population in ascending order.
    case population_asc
      
    /// Sort by population in descending order.
    case population_dec
      
    /// Sort by area in ascending order.
    case area_asc
      
    /// Sort by area in descending order.
    case area_dec
      
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
 Represents a model for country-related information conforming to Codable, Identifiable, and Equatable protocols.

 - Parameters:
   - id: The identifier for the country, which is derived from its name.
   - name: The name of the country.
   - capital: The capital city of the country.
   - languages: An array of languages spoken in the country.
   - population: The population of the country.
   - flag: The URL or identifier for the country's flag.
   - region: The geographical region to which the country belongs.
   - area: The total land area of the country.
   - favorited: A boolean indicating whether the country is marked as a favorite.
   - populationRank: The rank of the country based on population.
   - populationPercentage: The percentage of the global population represented by the country.
   - areaRank: The rank of the country based on land area.
   - areaPercentage: The percentage of the global land area represented by the country.
   - populationDensityRank: The rank of the country based on population density.
   - populationDensity: The calculated population density of the country.

 - Note:
   This struct serves as a data model for country-related information. It conforms to Codable for easy serialization, Identifiable for use in SwiftUI lists, and Equatable for comparison. The computed property `id` is derived from the country's name, and various statistical properties provide additional insights into the country's population, area, and density. The default values in the initializer are provided to handle optional parameters and set default values if not provided.

 Example:
 ```swift
 let country = Country(name: "Canada", population: 38008005, area: 9976140)
 print(country.populationDensity) // Output: 3.81
 */

struct Country: Codable, Identifiable, Equatable {
    var id: String {
        return name
    }
    let name: String
    let capital: String?
    let languages: [String]?
    let population: Double?
    let flag: String?
    let region: String?
    let area: Double?
    var favorited: Bool?
    
    //statistics
    var populationRank: Int?
    var populationPercentage: Double?
    var areaRank: Int?
    var areaPercentage: Double?
    var populationDensityRank: Int?
  

    var populationDensity: Double {
        if let area = self.area, let population = self.population {
            if (area != 0.0) && (population != 0.0) {
                let actualPopulation = population
                return actualPopulation / area
            }
        }
        return 0.0
    }

    init(
        name: String,
        capital: String = "",
        languages: [String] = [],
        population: Double = 0.0,
        flag: String = "",
        region: String = "UndefinedRegion",
        area: Double = 0.0,
        favorited: Bool = false) {
            self.capital = capital
            self.name = name.uppercased()
            self.languages = languages
            self.population = population
            self.flag = flag
            self.region = region
            self.area = area
            self.favorited = favorited
        }

    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                    rhs.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
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



/**
 Enum representing different grouping options.
 */
enum GROUP_BY {
    /// Indicates no grouping.
    case none
    
    /// Group items by area.
    case area
}
