    //
    //  Country.swift
    //  Country Map App
    //
    //  Created by Serdar Ulutas on 2023-11-11.
    //

    import Foundation


    class CountryViewModel: ObservableObject {
        var masterCountryList: [Country] = []
        var masterFavoriteList: [Country] = []
        
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
        
        @Published var areaStats:[ChartData] = []
        @Published var populationStats:[ChartData] = []
        @Published var densityStats:[ChartData] = []

    
        
        var getTotalPopulation: Double {
            return ceil(totalPopulation)
        }
        
        var getTotalArea: Double {
            return ceil(totalArea)
        }
     
        //statistical
         var totalPopulation: Double = 0
         var totalArea: Double = 0
        
        func retrieve() {
            Task {
                do {
                    DispatchQueue.main.async {

                        self.allCountriesStatus = .loading
                        self.favCountriesStatus = .loading
                    }
                    
                    
                    self.readFavoritesFromStorage()
                    try await fetchData()

                    for (index, var country) in self.masterCountryList.enumerated() {
                        country.favorited = false
                        if self.masterFavoriteList.firstIndex(where: { $0.name.lowercased() == country.name.lowercased()}) != nil {
                            country.favorited = true
                        }
                        
                        if let area = country.area {
                            totalArea += area
                        }
                        if let population = country.population{
                            totalPopulation += population
                        }
                        self.masterCountryList[index] = country
                    }
                    

                    // for statistics
                    let populationRankArray:[Country]   = self.masterCountryList.sorted(by: { (country1, country2) -> Bool in
                        return compareCountries(country1, country2, SORT_BY.population_dec)
                    })
                    
                    // set charts data
                    
                    
                    let areaRankArray:[Country]   = self.masterCountryList.sorted(by: { (country1, country2) -> Bool in
                        return compareCountries(country1, country2, SORT_BY.area_dec)
                    })
                    
                    let densityRankArray:[Country]   = self.masterCountryList.sorted(by: { (country1, country2) -> Bool in
                        return compareCountries(country1, country2, SORT_BY.density_desc)
                    })
                    
                    
                      // Loop again to set percentage
                    for (index, var country) in self.masterCountryList.enumerated() {
                        if let area = country.area{
                            if (totalArea > 0){
                                country.areaPercentage =  (area / totalArea * 100).rounded(toPlaces: 2)
                            }
                        }
                        if let population = country.population {
                            if (totalPopulation > 0){
                                country.populationPercentage = (population / totalPopulation * 100).rounded(toPlaces: 2)
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
                    
                    
                    // create statistics
                    let top10ByArea = Array(areaRankArray.prefix(10))
                    let top10ByPopulation = Array(populationRankArray.prefix(10))
                    let top10ByDensity = Array(densityRankArray.prefix(10))

                    var tempTotal:Double = 0.0
                    for country in top10ByArea {
                        if let area = country.area {
                            tempTotal = tempTotal + area
                            
                                areaStats.append(ChartData(type: country.name, value: area))
                            
                        }
                    }
                  
                    areaStats.append(ChartData(type:"Rest of the World", value: ceil(totalArea - tempTotal)))
              
                    tempTotal = 0.0
                    for country in top10ByPopulation {
                        if let population = country.population {
                            tempTotal = tempTotal + population
                            populationStats.append(ChartData(type: country.name, value: population))
                        }
                    }
                    populationStats.append(ChartData(type:"Rest of the World", value: ceil(totalPopulation - tempTotal)))
                    
                    
                    for country in top10ByDensity {
                        densityStats.append(ChartData(type: country.name, value: country.populationDensity))
                    }
                    if (totalArea > 0) && (totalPopulation > 0){
                        let worldDensity: Double = ceil(totalPopulation / totalArea)
                        densityStats.append(ChartData(type: "World Average", value: worldDensity))
                    }
                    
                    
                    DispatchQueue.main.async {
                        self.allCountries = self.masterCountryList
                        self.sortCountries()
                        self.sortFavorites()
                        self.allCountriesStatus = .idle
                        self.favCountriesStatus = .idle
                    }
                } catch {
                    print("Error: \(error)")
                    DispatchQueue.main.async {
                        self.allCountriesStatus = .error
                        self.favCountriesStatus = .error
                    }
                }
            }
        }

        func readFavoritesFromStorage() {
            if let savedData = UserDefaults.standard.data(forKey: Constants.FAVORITES_KEY),
               let decodedArray = try? JSONDecoder().decode([Country].self, from: savedData){
                masterFavoriteList = decodedArray
            } else {
                // Handle the case where the array of objects couldn't be retrieved or decoded
                print("Unable to retrieve or decode the array of objects from UserDefaults.")
                masterFavoriteList = []
            }
            applyFilterToFavorites()
        }
        
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
     

        func toggleFavorite(name: String) {
            if let masterListIndex = masterCountryList.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) {
                var country = masterCountryList[masterListIndex]
                var newFavList: [Country] = []
                var newCountryList:[Country] = masterCountryList
                
                if let fav = country.favorited {
                    if (fav){
                        country.favorited = false
                    }else{
                        country.favorited = true
                    }
                }else{
                    country.favorited = true
                }
                
                newCountryList[masterListIndex] = country
                
                
                if let favorited = country.favorited {
                    if (favorited){
                        if masterFavoriteList.firstIndex(where: { $0.name.lowercased() == name.lowercased() }) == nil {
                            newFavList = masterFavoriteList
                            newFavList.append(country)
                            
                        }
                    }else{
                        if let favoriteIndex = masterFavoriteList.firstIndex(where: {$0.name.lowercased() == name.lowercased()}) {
                            newFavList = masterFavoriteList
                            newFavList.remove(at: favoriteIndex)
                             
                        }
                    }
                }
               
                if let encodedData = try? JSONEncoder().encode(masterFavoriteList) {
                    // Save the encoded data to UserDefaults
                    UserDefaults.standard.set(encodedData, forKey: Constants.FAVORITES_KEY)
                } else {
                    // Handle the encoding failure
                    print("Failed to encode the array of objects.")
                }
                DispatchQueue.main.async {
                    self.masterCountryList = newCountryList
                    self.masterFavoriteList = newFavList
                    self.filterCountries()
                    self.filterFavorites()
                    self.sortCountries()
                    self.objectWillChange.send() // Explicitly notify SwiftUI

                }
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

      private func applyFilterToCountries() {
        DispatchQueue.main.async {
            self.allCountriesStatus = .loading
        }

        var list:[Country] = masterCountryList

        // apply filter
        let searchText = allCountriesSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchText.isEmpty {
          list = list.filter { country in
            return country.name.range(of: searchText, options: .caseInsensitive) != nil
          }
        }

          list = list.sorted(by: { (country1, country2) -> Bool in
              return compareCountries(country1, country2, allCountriesSortBy)
          })
        // Dispatch the update to the main thread
        DispatchQueue.main.async {
          self.allCountries = list
          self.allCountriesStatus = .idle
        }
      }

      private func applyFilterToFavorites() {

        DispatchQueue.main.async {
          self.favCountriesStatus = .loading
        }
        // apply sort
        var list: [Country] = masterFavoriteList
        list.sort(by: { (country1, country2) -> Bool in
          return compareCountries(country1, country2, favCountriesSortBy)
        })

        // apply filter
        let searchText = favCountriesSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !searchText.isEmpty {
          list = list.filter { country in
            return country.name.range(of: searchText, options: .caseInsensitive) != nil
          }
        }

        // Dispatch the update to the main thread
        DispatchQueue.main.async {
          self.favCountries = list
          self.favCountriesStatus = .idle
        }
      }

      

      private func fetchData() async throws {
        if let url = URL(
          string: "https://raw.githubusercontent.com/shah0150/data/main/countries_data.json")
        {
          var request = URLRequest(url: url)
          request.httpMethod = "GET"

          let (data, _) = try await URLSession.shared.data(for: request)

          let decoder = JSONDecoder()
          let result = try decoder.decode([Country].self, from: data)

          self.masterCountryList = result
        }
      }
    }

