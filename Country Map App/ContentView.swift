//
//  ContentView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-11.



import SwiftUI


// MARK: Main Content View
struct ContentView: View {
    // ViewModel to manage country data
    @ObservedObject var countryModel: CountryViewModel = CountryViewModel()
    
    // State variable to track the selected segment in the picker

    @State private var selectedSegment = 0
    
    var body: some View {
        ZStack {
            VStack {
                // Segmented Picker for switching between views
                Picker("", selection: $selectedSegment) {
                    Text("All Countries").tag(0)
                    Text("Favorites").tag(1)
                    Text("Charts").tag(2)
                }.pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .cornerRadius(8)
                
                // Display different views based on the selected segment
                if selectedSegment == 0 {
                    //All countries view
                    CountryListView(model: countryModel,
                                    data: $countryModel.allCountries,
                                    status: $countryModel.allCountriesStatus,
                                    sortValue: $countryModel.allCountriesSortBy,
                                    searchValue: $countryModel.allCountriesSearchText,
                                    search: countryModel.filterCountries,
                                    sort: countryModel.sortCountries,
                                    toggleFavorite: countryModel.toggleFavorite,
                                    searchTextPlaceholder: "Type to search all countries")
                } else if selectedSegment == 1 {
                    // Favorites view
                    CountryListView(model: countryModel,
                                    data: $countryModel.favCountries,
                                    status: $countryModel.favCountriesStatus,
                                    sortValue: $countryModel.favCountriesSortBy,
                                    searchValue: $countryModel.favCountriesSearchText,
                                    search: countryModel.filterFavorites,
                                    sort: countryModel.sortFavorites,
                                    toggleFavorite: countryModel.toggleFavorite,
                                    searchTextPlaceholder: "Type to search favorites",
                                    emptyListText: "No favorites yet.")
               
                } else if selectedSegment == 2 {
                    // Chart data view
                    ChartView(model: countryModel)
                }
            }.onAppear {
                countryModel.retrieve()
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
