//
//  Region.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-19.
//

import Foundation

struct Region: Identifiable, Equatable {
    var id: String {
        return name
    }
    let name: String
    var countries: [String]?
    var languages: [String]?
    var population: Double? = 0
    var area: Double? = 0
    
    // Computed property to calculate population density
    var populationDensity: Double {
        guard let area = area,let population = population, area != 0.0 else {
            return 0.0
        }
        return population / area
    }
    

    // Equatable conformance for comparison
    static func == (lhs: Region, rhs: Region) -> Bool {
        return lhs.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                    rhs.name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }
}
