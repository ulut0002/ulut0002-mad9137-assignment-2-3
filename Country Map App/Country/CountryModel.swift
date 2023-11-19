    //
    //  Country.swift
    //  Country Map App
    //
    //  Created by Serdar Ulutas on 2023-11-11.
    //

    import Foundation

    // MARK: - CountryViewModel

    class CountryViewModel: ObservableObject {
        // MARK: Properties
        
        // Master lists to store all countries and favorite countries.
        // This list never changes except "toggleFavorite"
        var masterCountryList: [Country] = []
        var masterFavoriteList: [Country] = []
        
        // Published properties for SwiftUI updates
        @Published var allCountries:[Country] = []
        @Published var allCountriesStatus:FETCH_STATUS = .idle
        @Published var allCountriesSearchText:String = ""
        @Published var allCountriesSortBy: SORT_BY = .alphabetically_asc
        @Published var allCountriesGroupBy: GROUP_BY = .none
        
        @Published var favCountries:[Country] = []
        @Published var favCountriesStatus:FETCH_STATUS = .idle
        @Published var favCountriesSearchText:String = ""
        @Published var favCountriesSortBy: SORT_BY = .alphabetically_asc
        @Published var favCountriesGroupBy: GROUP_BY = .none
        
        // Published properties for statistical data and charts
        @Published var areaStats:[ChartData] = []
        @Published var populationStats:[ChartData] = []
        @Published var densityStats:[ChartData] = []
        
        // Total population and area for statistical calculations
        var totalPopulation: Double = 0
        var totalArea: Double = 0
    
        // Computed properties for total population and area
        var getTotalPopulation: Double {
            return ceil(totalPopulation)
        }
        
        var getTotalArea: Double {
            return ceil(totalArea)
        }
     
        // MARK: Methods
        func sortCountries() {
            allCountries = sortCountryList(source: allCountries, sortBy: allCountriesSortBy)
        }
        
        func sortFavorites() {
            favCountries = sortCountryList(source: favCountries, sortBy: favCountriesSortBy)
        }

        func filterCountries() {
            // filter first, sort later
            let filteredCountries = filterCountryList(source: masterCountryList , searchText: allCountriesSearchText)
            allCountries = sortCountryList(source: filteredCountries, sortBy: allCountriesSortBy)
        }


        func filterFavorites() {
            // filter first, sort later
            let filteredCountries = filterCountryList(source: masterFavoriteList , searchText: favCountriesSearchText)
            favCountries = sortCountryList(source: filteredCountries, sortBy: favCountriesSortBy)
        }
     

        func toggleFavorite(name: String) {
            if let masterListIndex = masterCountryList.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
                masterCountryList[masterListIndex].favorited?.toggle()
                
                if let countryIndex = allCountries.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
                    allCountries[countryIndex].favorited?.toggle()
                }
                if let favorited = masterCountryList[masterListIndex].favorited {
                    if (favorited){
                        if masterFavoriteList.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) == nil {
                            masterFavoriteList.append(masterCountryList[masterListIndex])
                        }
                    }else{
                        if let favoriteIndex = masterFavoriteList.firstIndex(where: {$0.name.lowercased() == name.lowercased()}) {
                            masterFavoriteList.remove(at: favoriteIndex)
                        }
                    }
                }
                    
                if let encodedData = try? JSONEncoder().encode(masterFavoriteList) {
                    UserDefaults.standard.set(encodedData, forKey: Constants.FAVORITES_KEY)
                        
                } else {
                    print("Failed to encode the array of objects.")
                }
                filterFavorites()
            }
        }
        
        
        private func sortCountryList(source: [Country], sortBy: SORT_BY) -> [Country]{
            var list:[Country] = []
            list = source.sorted(by: { (country1, country2) -> Bool in
                return compareCountries(country1, country2, sortBy)
            })
            return list
        }
        
        private func filterCountryList(source:[Country], searchText: String) -> [Country]{
            var list:[Country] = source
            
            let searchTextClean = allCountriesSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
            if !searchTextClean.isEmpty {
                list = source.filter { country in
                  return country.name.range(of: searchTextClean, options: .caseInsensitive) != nil
                }
            }
            return list
        }
    }


// MARK: - Extension Methods

extension CountryViewModel{
    private func fetchData() async throws -> [Country] {
        if let url = URL(string: "https://raw.githubusercontent.com/shah0150/data/main/countries_data.json") {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            let (data, _) = try await URLSession.shared.data(for: request)

            let decoder = JSONDecoder()
            let result = try decoder.decode([Country].self, from: data)
            return result
        }
        return []
    }
    
    // Main method to retrieve and process country data
    func retrieve() {
        Task {
            do {
                DispatchQueue.main.async {
                    // Set loading status for all countries and favorites
                    self.allCountriesStatus = .loading
                    self.favCountriesStatus = .loading
                }
                
                masterFavoriteList =  readFavoritesFromStorage()
                masterCountryList = try await fetchData()

                
                // Update the master country list with favorite status and calculate total area and population
                for (index, var country) in self.masterCountryList.enumerated() {
                    country.favorited = false
                    if self.masterFavoriteList.firstIndex(where: { $0.name.lowercased() == country.name.lowercased()}) != nil {
                        country.favorited = true
                    }
                    
                    if let area = country.area {
                        self.totalArea += area
                    }
                    if let population = country.population{
                        self.totalPopulation += population
                    }
                    self.masterCountryList[index] = country
                }
                
                // Sort countries by population and area for statistical calculations
                let populationRankArray:[Country]   = self.masterCountryList.sorted(by: {compareCountries($0, $1, .population_dec)})
                let areaRankArray:[Country]   = self.masterCountryList.sorted(by: {compareCountries($0, $1, .area_dec)})
                let densityRankArray:[Country]   = self.masterCountryList.sorted(by: {compareCountries($0, $1, .density_desc)})
                
                
                
                // Knowing total population, area and sorted stats, loop again to set percentage and ranks
                for (index, var country) in self.masterCountryList.enumerated() {
                    if let area = country.area{
                        if (totalArea > 0){
                            country.areaPercentage =  (area / totalArea * 100).rounded(toPlaces: 2) //global rank
                        }
                    }
                    if let population = country.population {
                        if (totalPopulation > 0){
                            country.populationPercentage = (population / totalPopulation * 100).rounded(toPlaces: 2) //global rank
                        }
                    }
                    
                    
                    
                    
                    if let areaIndex =  areaRankArray.firstIndex(where: { $0.name.lowercased() == country.name.lowercased()}) {
                        country.areaRank = areaIndex + 1
                    }
                    if let populationIndex = populationRankArray.firstIndex(where: { $0.name.lowercased() == country.name.lowercased()}){
                        country.populationRank = populationIndex + 1
                    }
                    
                    if let densityIndex = densityRankArray.firstIndex(where: { $0.name.lowercased() == country.name.lowercased()}){
                        country.populationDensityRank = densityIndex + 1
                    }
                    self.masterCountryList[index] = country
                }
                
                
                // Create statistics for charts
                let top10ByArea = Array(areaRankArray.prefix(10))
                let top10ByPopulation = Array(populationRankArray.prefix(10))
                let top10ByDensity = Array(densityRankArray.prefix(10))

                for country in top10ByArea {
                    if let area = country.area {
                        areaStats.append(ChartData(type: country.name, value: area))
                    }
                }
                        
                for country in top10ByPopulation {
                    if let population = country.population {
                        populationStats.append(ChartData(type: country.name, value: population))
                    }
                }
                
                
                for country in top10ByDensity {
                    densityStats.append(ChartData(type: country.name, value: country.populationDensity))
                }
               
                // generate allCountries and allFavorites from the master lists
                filterCountries()
                filterFavorites()
                
                DispatchQueue.main.async {
                    self.allCountriesStatus = .idle
                    self.favCountriesStatus = .idle
                }
            } catch {
                print("Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.allCountriesStatus = .error
                    self.favCountriesStatus = .error
                }
            }
        }
    }

    func readFavoritesFromStorage() -> [Country] {
        if let savedData = UserDefaults.standard.data(forKey: Constants.FAVORITES_KEY),
           let decodedArray = try? JSONDecoder().decode([Country].self, from: savedData){
                return decodedArray
            } else {
                // Handle the case where the array of objects couldn't be retrieved or decoded
                print("Unable to retrieve or decode the array of objects from UserDefaults.")
                return []
            }
        }
}
