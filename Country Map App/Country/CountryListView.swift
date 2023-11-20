//
//  CountryListView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-19.
//

import SwiftUI


// MARK: CountryListView

struct CountryListView: View{
    @ObservedObject var model: CountryViewModel
    
    // Binding variables to manage data, status, sorting, and searching
    @Binding var data: [Country]
    @Binding var status: FETCH_STATUS
    @Binding var sortValue: SORT_BY
    @Binding var searchValue: String
    
    // Callbacks for performing search, sort, and toggling favorites
    var search: () -> Void
    var sort: () -> Void
    var toggleFavorite: (_ name: String) -> Void
    
    // Optional parameters for customization
    var searchTextPlaceholder: String? = "Search"
    var emptyListText: String = "Empty list..."
    
    var body: some View{
        
        // Display error view if the status is error
        if status == .error {
            FetchErrorView()
        }
        
        // Display loading view if the status is loading
        if status == .loading {
            LoadingView()
        }
        
        
        // Display content when the status is idle
        if (status == .idle){
            // Search bar for sorting and searching
            SearchBarView(sortValue: $sortValue,
                          searchValue: $searchValue,
                          search: search,
                          sort: sort,
                          searchBarPlaceHolder: searchTextPlaceholder ?? "Search")
            

            if  (data.isEmpty){
                // Display appropriate messages when the data is empty
                VStack{
                    Spacer()
                    if (searchValue.isEmpty){
                        Text(emptyListText)
                    }else{
                        Text("0 results")
                    }
                    Spacer()
                }
            }else{
                // Display the list of countries

                List{
                    LazyVStack{
                        ForEach(Array(data.enumerated()), id:\.element.id){ index, country in
                            CountryListItemView(country: country,
                                                index: index,
                                                totalPopulation: model.getTotalPopulation,
                                                totalArea: model.getTotalArea,
                                                handleFavoriteChange: toggleFavorite)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}
