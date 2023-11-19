//
//  CountryModel.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-19.
//

import Foundation

/**
 Represents a model for country-related information conforming to Codable, Identifiable, and Equatable protocols.
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

    // Computed property to calculate population density
    var populationDensity: Double {
        guard let area = area,let population = population, area != 0.0 else {
            return 0.0
        }
        return population / area
    }
    

    // Equatable conformance for comparison
    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                    rhs.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() &&
        lhs.favorited == rhs.favorited
    }
}
