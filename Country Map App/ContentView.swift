    //
    //  ContentView.swift
    //  Country Map App
    //
    //  Created by Serdar Ulutas on 2023-11-11.
    // SVG Image: https://stackoverflow.com/questions/73100626/uploading-svg-images-to-swiftui/73401775#73401775
    //


import SwiftUI
//import Charts
import SDWebImageSVGCoder
import SDWebImageSwiftUI

    struct ContentView: View {
      @ObservedObject var countryModel: CountryViewModel = CountryViewModel()
      @State private var selectedSegment = 1
        
      var body: some View {
          
          ZStack {
              VStack {
              Picker("Select View", selection: $selectedSegment) {
                Text("All Countries").tag(0)
                Text("Favorites").tag(1)
                Text("Charts").tag(2)
              }.pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                  
                

              if selectedSegment == 0 {
                  CountryListView(model: countryModel,
                                    data: $countryModel.allCountries,
                                    status: $countryModel.allCountriesStatus,
                                    sortValue: $countryModel.allCountriesSortBy,
                                    searchValue: $countryModel.allCountriesSearchText,
                                    search: countryModel.filterCountries,
                                         sort: countryModel.sortCountries,
                                         toggleFavorite: countryModel.toggleFavorite
                                        )

              } else if selectedSegment == 1 {

                  CountryListView( 
                    model: countryModel,
                    data: $countryModel.favCountries,
                                   status: $countryModel.favCountriesStatus,
                                   sortValue: $countryModel.favCountriesSortBy,
                                   searchValue: $countryModel.favCountriesSearchText,
                                  search: countryModel.filterFavorites,
                                  sort: countryModel.sortFavorites,
                                  toggleFavorite: countryModel.toggleFavorite,
                  emptyListText: "No favorites yet.")
              } else if selectedSegment == 2 {
                  // chart data
                  ChartView(model: countryModel)
              }
              }
              .onAppear {
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

    // handles both all-countries view and favorites view

    struct CountryListView: View{
        @ObservedObject var model: CountryViewModel
        @Binding var data: [Country]
        @Binding var status: FETCH_STATUS
        @Binding var sortValue: SORT_BY
        @Binding var searchValue: String
        
        var search: () -> Void
        var sort: () -> Void
        var toggleFavorite: (_ name: String) -> Void
        var searchTextPlaceholder: String? = "Search"
        var emptyListText: String = "Empty list..."
        
        var body: some View{
            if status == .loading {
                VStack{
                    Spacer()
                    ProgressView().padding(16)
                    
                    Text("Loading.. Please wait")
                    
                    Spacer()
                }
            }
            
            if (status == .error) {
                VStack{
                    Spacer()
                    Text("Fetch error!")
                    Spacer()
                }
            }
            
            if (status == .idle){
                SearchBarView(sortValue: $sortValue, 
                              searchValue: $searchValue,
                              search: search,
                              sort: sort,
                              searchBarPlaceHolder: searchTextPlaceholder ?? "Search")
                
                if  (data.isEmpty){
                    VStack{
                        Spacer()
                        Text(emptyListText)
                        Spacer()
                    }
                }else{
                    //display items
                    List{
                        LazyVStack{
                            ForEach(data, id:\.id){ country in
                                CountryListItemView(country: country,
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

    struct SearchBarView: View{
        @Binding var sortValue: SORT_BY
        @Binding var searchValue: String
        var search: () -> Void
        var sort: () -> Void
        var searchBarPlaceHolder: String = "Search"


        
        var body: some View{
            VStack{
                HStack{
                    TextField(searchBarPlaceHolder, text: $searchValue)
                        .padding(8)
                      .background(Color(.systemGray6))
                      .cornerRadius(8)
                      .onChange(of: searchValue){
                          search()
                      }
                    Button(action: {
                        searchValue = ""
                    }) {
                      Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                    }
                    .opacity(searchValue.isEmpty ? 0 : 1)
                    
                    Menu("",systemImage: "arrow.up.arrow.down"){
                        Button("Name (A..Z)") {
                            sortValue = SORT_BY.alphabetically_asc
                                              sort()
                        }
                        Button("Name (Z..A)") {
                            sortValue = SORT_BY.alphabetically_dec

                                               sort()
                                           }
                                           Button("Population (Asc.)") {
                                               sortValue = SORT_BY.population_asc
                                               sort()
                                           }
                                           Button("Population (Desc.)") {
                                               sortValue = SORT_BY.population_dec
                                               sort()
                                           }
                                           Button("Area (Asc.)") {
                                               sortValue = SORT_BY.area_asc
                                               sort()
                                           }
                                           Button("Area (Desc.)") {
                                               sortValue = SORT_BY.area_dec
                                               sort()
                                           }
                                           Button("Population Density (Asc.)") {
                                               sortValue = SORT_BY.density_asc
                                               sort()
                                           }
                                           Button("Population Density (Desc.)") {
                                               sortValue = SORT_BY.density_desc
                                               sort()
                                           }
                    

                    }
                }.padding(.horizontal, 16)
        
            }
        }
    }


    struct CountryListItemView: View {
      var country: Country
        var totalPopulation: Double
        var totalArea: Double
        var handleFavoriteChange: (_ name: String) -> Void

      @State private var isSheetPresented = false
      
      var body: some View {

        VStack {
          HStack {
            if let url = country.flag {
              HStack {

                  
                                WebImage(url: URL(string: url), options: [], context: [.imageThumbnailPixelSize: CGSize.zero])
                             .placeholder { ProgressView().frame(width: 12, height: 12) }
                             .resizable()
                             .frame(width: 40, height: 40)
                             .aspectRatio(contentMode: .fit)
                             .clipShape(Circle())
                             .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                             .shadow(radius: 2)
              }.padding(8)

            }

            Text(country.name)
              .font(.headline)

            Spacer()  // Pushes the text to the leading edge

              if let favorited = country.favorited {
                  if (favorited) {
                  Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .padding(.trailing, 4)
                    .onTapGesture {
                        handleFavoriteChange(country.name)
                    }
                } else {
                  Image(systemName: "star")
                    .foregroundColor(.yellow)
                    .padding(.trailing, 4)
                    .onTapGesture {
                        handleFavoriteChange(country.name)
                    }
                }
              }else{
                  Image(systemName: "star")
                    .foregroundColor(.yellow)
                    .padding(.trailing, 4)
                    .onTapGesture {
                        handleFavoriteChange(country.name)
                    }
              }
                
            }
            
          
          .padding(.horizontal, 16)
          .background(Color.white)
          .cornerRadius(10)
          .shadow(radius: 2)
          .padding(.vertical, 2)
         
        }
        .onTapGesture {
          //                isSheetPresented.toggle()
          isSheetPresented = true
        }
        .sheet(isPresented: $isSheetPresented) {

            CountrySheetView(country: country, totalPopulation: totalPopulation, totalArea: totalArea, isSheetPresented: $isSheetPresented, toggleFavorite: handleFavoriteChange)
        }
      }

    }




