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
        // The master list never changes except when "toggleFavorite" is called
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
        
        
        // Region wide statistical data
        var regions: [Region] = []
        @Published var regionByPopulationStats: [ChartData] = []
        @Published var regionByLanguageCountStats: [ChartData] = []
        @Published var regionByCountryCountStats: [ChartData] = []

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
        // Sort is performed in currently displayed list.
        // Filter on the other hand is performed on master list, and then sort() is performed
        func sortCountries() {
            allCountries = sortCountryList(source: allCountries, sortBy: allCountriesSortBy)
        }
        
        func sortFavorites() {
            favCountries = sortCountryList(source: favCountries, sortBy: favCountriesSortBy)
        }

        func filterCountries() {
            let filteredCountries = filterCountryList(source: masterCountryList , searchText: allCountriesSearchText)
            allCountries = sortCountryList(source: filteredCountries, sortBy: allCountriesSortBy)
        }


        func filterFavorites() {
            let filteredCountries = filterCountryList(source: masterFavoriteList , searchText: favCountriesSearchText)
            favCountries = sortCountryList(source: filteredCountries, sortBy: favCountriesSortBy)
        }
     

        // Toggle favorite status for the specified country
        func toggleFavorite(name: String) {
            if let masterListIndex = masterCountryList.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
                masterCountryList[masterListIndex].favorited?.toggle()
                
                // Update the favorite status in the displayed lists
                if let countryIndex = allCountries.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
                    allCountries[countryIndex].favorited?.toggle()
                }
                
                // Manage the master favorite list
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
                    
                // Save the updated favorite list to UserDefaults
                if let encodedData = try? JSONEncoder().encode(masterFavoriteList) {
                    UserDefaults.standard.set(encodedData, forKey: CONSTANTS.FAVORITES_KEY)
                        
                } else {
                    print("Failed to encode the array of objects.")
                }
                
                // Refresh the displayed favorite list
                filterFavorites()
            }
        }
        
        // MARK: Private Helper Methods
        private func sortCountryList(source: [Country], sortBy: SORT_BY) -> [Country]{
            var list:[Country] = []
            list = source.sorted(by: { (country1, country2) -> Bool in
                return compareCountries(country1, country2, sortBy)
            })
            return list
        }
        
        private func filterCountryList(source:[Country], searchText: String) -> [Country]{
            var list:[Country] = source
            
            let searchTextClean = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    // Asynchronous method to fetch country data from the specified URL
    private func fetchData() async throws -> [Country] {
        if let url = URL(string: CONSTANTS.DATA_URL ) {
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
                
                // Read favorite countries from UserDefaults
                masterFavoriteList =  readFavoritesFromStorage()
                
                // Fetch country data asynchronously
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
                
                let populationRankArray:[Country]   = self.masterCountryList.sorted(by: {compareCountries($0, $1, .population_desc)})
                let areaRankArray:[Country]   = self.masterCountryList.sorted(by: {compareCountries($0, $1, .area_desc)})
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
                    
                    addCountryToRegionArray(country: country)
                }
                
                
                // Create statistics for charts
                let top10ByArea = Array(areaRankArray.prefix(10))
                let top10ByPopulation = Array(populationRankArray.prefix(10))
                let top10ByDensity = Array(densityRankArray.prefix(10))

                for country in top10ByArea {
                    if let area = country.area {
                        DispatchQueue.main.async {
                            self.areaStats.append(ChartData(type: country.name, value: area))
                        }
                    }
                }
                        
                for country in top10ByPopulation {
                    if let population = country.population {
                        DispatchQueue.main.async {
                            self.populationStats.append(ChartData(type: country.name, value: population))
                        }
                    }
                }
                
                
                for country in top10ByDensity {
                    DispatchQueue.main.async {
                        self.densityStats.append(ChartData(type: country.name, value: country.populationDensity))
                    }
                }
               
                // generate allCountries and allFavorites from the master lists
                
                DispatchQueue.main.async {
                    self.filterCountries()
                    self.filterFavorites()
                }
                
                
            
                
                for region in regions {
                    if let population = region.population {
                        DispatchQueue.main.async {
                            self.regionByPopulationStats.append(ChartData(type: region.name, value: population))
                        }
                    }
                    
                    if let language = region.languages {
                        DispatchQueue.main.async {
                            self.regionByLanguageCountStats.append(ChartData(type: region.name, value: Double(language.count)))
                        }

                    }
                    
                    if let countries = region.countries {
                        DispatchQueue.main.async {
                            self.regionByCountryCountStats.append(ChartData(type: region.name, value: Double(countries.count)))
                        }

                    }
                }
                
                
                
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

    // Reads the list of favorite countries from UserDefaults.
    // Returns: An array of Country objects representing favorite countries.
    private func readFavoritesFromStorage() -> [Country] {
        if let savedData = UserDefaults.standard.data(forKey: CONSTANTS.FAVORITES_KEY),
           let decodedArray = try? JSONDecoder().decode([Country].self, from: savedData){
                return decodedArray
            } else {
                // Handle the case where the array of objects couldn't be retrieved or decoded
                print("Unable to retrieve or decode the array of objects from UserDefaults.")
                return []
            }
        }
    
    
    // Finds the index of a region in the regions array based on its name.
    // Parameters:
    // - regionName: The name of the region to search for.
    // Returns: The index of the region if found, otherwise -1.
    private func findRegionIndex(regionName: String) -> Int{
        let regionNameClean = regionName.trimmingCharacters(in: .whitespacesAndNewlines)
        if (!regionNameClean.isEmpty){
            if let idx = regions.firstIndex(where: {$0.id.trimmingCharacters(in: .whitespacesAndNewlines) == regionNameClean}){
                return idx
            }else{
                return -1
            }
        }
        return -1
    }
    
    
    // Adds a country to the appropriate region in the regions array.
    // Updates the region's list of countries, languages, population, and area.
    // Parameters:
    // - country: The Country object to be added to the region.
    func addCountryToRegionArray(country: Country){
        
        
        if let regionText = country.region{
            // Check if the region should be excluded
            if CONSTANTS.EXCLUDED_REGIONS.contains(where: {$0.trimmingCharacters(in: .whitespacesAndNewlines) == regionText.trimmingCharacters(in: .whitespacesAndNewlines)}){
                return;
            }
            
            var regionIndex = findRegionIndex(regionName: regionText)
            if (regionIndex < 0){
                // add a new region to the list
                var newRegion = Region(name: regionText.trimmingCharacters(in: .whitespacesAndNewlines))
                newRegion.countries = []
                newRegion.languages = []
                newRegion.population = 0
                newRegion.area = 0
                regions.append(newRegion)
                regionIndex = regions.count - 1
            }else {
             // do nothing
            }
            
            
            // Check if the country exists or not in the region
            if var countries = regions[regionIndex].countries {
                if (!countries.contains(where: {$0.trimmingCharacters(in: .whitespacesAndNewlines) == country.name.trimmingCharacters(in: .whitespacesAndNewlines)})){
                    // Append the country to the list
                    countries.append(country.name)
                }
                regions[regionIndex].countries = countries
            }
            
            // Check if the language exists or not in the region
            if var languages = regions[regionIndex].languages, let countryLanguages = country.languages{
                for countryLanguge in countryLanguages {
                    if (!languages.contains(where: {$0.trimmingCharacters(in: .whitespacesAndNewlines) == countryLanguge})){
                        // Add the language to the list
                        languages.append(countryLanguge)
                    }
                }
                regions[regionIndex].languages = languages
            }
            
            if let pop = country.population{
                regions[regionIndex].population! += pop
            }
            
            if let area = country.area{
                regions[regionIndex].area! += area
            }
            
        }
    }
}
