//
//  SearchBarView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-19.
//

import SwiftUI

// MARK: - SearchBarView


struct SearchBarView: View{
    @Binding var sortValue: SORT_BY
    @Binding var searchValue: String
    var search: () -> Void
    var sort: () -> Void
    var searchBarPlaceHolder: String = "Search"

    func updateSort(choosenSortMethod: SORT_BY){
        sortValue = choosenSortMethod
        sort()
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View{
        // Vertical stack to organize the content
        VStack{
            // Horizontal stack for the search bar and sorting menu
            HStack{
                Spacer()
                
                // TextField for entering search queries
                TextField(searchBarPlaceHolder, text: $searchValue)
                    .padding(8)
                    .background(colorScheme == .light ? Color(.systemGray6) : Color(.systemGray2) )
                    .cornerRadius(8)
                    .onChange(of: searchValue){
                        search()
                    }
                
                // Button to clear the search text
                Button(action: {
                    searchValue = ""
                }) {
                    Image(systemName: IMAGE_NAMES.CLEAR_TEXT)
                        .foregroundColor(.gray)
                }.opacity(searchValue.isEmpty ? 0 : 1)
                
                Menu("",systemImage: IMAGE_NAMES.SORT){
                    Button("Name (A..Z)") {
                        updateSort(choosenSortMethod:  SORT_BY.alphabetically_asc)
                    }
                    
                    Button("Name (Z..A)") {
                        updateSort(choosenSortMethod:  SORT_BY.alphabetically_desc)
                    }
                    
                    Button("Population (Asc.)") {
                        updateSort(choosenSortMethod: SORT_BY.population_asc)
                    }
                    
                    Button("Population (Desc.)") {
                        updateSort(choosenSortMethod: SORT_BY.population_desc)
                    }
                    
                    Button("Area (Asc.)") {
                        updateSort(choosenSortMethod: SORT_BY.area_asc)
                    }
                    
                    Button("Area (Desc.)") {
                        updateSort(choosenSortMethod: SORT_BY.area_desc)
                    }
                    
                    Button("Population Density (Asc.)") {
                        updateSort(choosenSortMethod: SORT_BY.density_asc)
                    }
                    
                    Button("Population Density (Desc.)") {
                        updateSort(choosenSortMethod: SORT_BY.density_desc)
                    }
                }.foregroundColor(colorScheme == .light ? Color.black : Color.white)
                Spacer()
            }
            .padding(.horizontal, 18)
                
        }
    }
}
