    //
    //  ContentView.swift
    //  Country Map App
    //
    //  Created by Serdar Ulutas on 2023-11-11.
    // SVG Image: https://stackoverflow.com/questions/73100626/uploading-svg-images-to-swiftui/73401775#73401775
    //

import SDWebImageSVGCoder
import SDWebImageSwiftUI
import SwiftUI
import Charts

    struct ContentView: View {
      @StateObject var countryModel: CountryViewModel = CountryViewModel()
      @State private var selectedSegment = 0
        
        

        
        
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
                                    data: countryModel.allCountries,
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
                    data: countryModel.favCountries,
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



struct ChartSection: View {
    var title: String
    var data: [ChartData]
    @State var displayAnnotations: Bool = false


    var body: some View {
        
        ZStack {
            Color.gray.opacity(0.1)
            VStack {
                Text(title).bold()
                Chart {
                    ForEach(data.indices, id: \.self) { index in
                        let datum = data[index]
                        
                        SectorMark(angle: .value(title, datum.value))
                            .annotation(position: .overlay, alignment: .center, content: {
                                if (displayAnnotations){
                                    Text("\(datum.type)")
                                        .font(.footnote)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.black.opacity(0.6))
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                        .offset(y: -10)
                                }
                            })
                            .foregroundStyle(by: .value("Type", datum.type))
                            .opacity(0.2)
                        
                        
                    }
                }.onTapGesture {
                    displayAnnotations.toggle()
                }
                .chartLegend(position: .top, alignment: .center, spacing: 10)

                .padding(.vertical, 10)
                .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/)
                .frame(minHeight: 400)
            }.padding(32)
        }
    }
}


struct ChartBar: View {
    var title: String
    var data: [ChartData]
    @State var displayAnnotations: Bool = false

    var body: some View{
        VStack{
            
        }
    }
}


struct ChartView: View {
    @ObservedObject var model: CountryViewModel
    var body: some View {
        let top10ByArea = model.areaStats
        let top10ByPopulation = model.populationStats
        let top10ByDensity = model.densityStats
        
        List{
            VStack(spacing: 32){
                ChartSection(title: "Top 10 countries by population", data: top10ByPopulation)
                ChartSection(title: "Top 10 countries by area", data: top10ByArea)
            }
        }.listStyle(PlainListStyle())
    
        
    }
}


    struct ContentView_Previews: PreviewProvider {
      static var previews: some View {
        ContentView()
      }
    }

    // handles both all-countries view and favorites view

    struct CountryListView: View{
        var model: CountryViewModel
         var data: [Country]
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
          print("Tabbed on \(country.name) \(isSheetPresented)")
        }
        .sheet(isPresented: $isSheetPresented) {

          CountrySheetView(country: country, totalPopulation: totalPopulation, totalArea: totalArea)
        }
      }

    }




    struct CountrySheetView: View {
        var country: Country
        var totalPopulation: Double
        var totalArea: Double
        
      

        
      var body: some View {
        
          
          ZStack {

              LinearGradient(gradient: Gradient(colors: [Constants.COLOR_BLUE_1, Constants.COLOR_BLUE_2]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea(.all)
              VStack(alignment: .center) {
              Text(country.name)
                .frame(alignment: .center)
                .font(.largeTitle)

              WebImage(
                url: URL(string: country.flag!), options: [],
                context: [.imageThumbnailPixelSize: CGSize.zero]
              )
              .placeholder { ProgressView().frame(width: 12, height: 12) }
              .resizable()
              .frame(width: 240, height: 180, alignment: .center)
              .aspectRatio(contentMode: .fit)
              .cornerRadius(20)

              if let capital = country.capital {
                HStack {
                  Text("Capital City:").bold().frame(alignment: .leading)
                  Text(capital)
                  Spacer()
                }.padding(.vertical, 8)
              }

              if let population = country.population {

                HStack {
                  Text("Population:").bold().frame(alignment: .leading)
                  Text(formatNumber(num: population))+Text(" people") +  Text(" (Rank: \(country.populationRank ?? 0))").font(.system(size: 15))
                  Spacer()
                }.padding(.vertical, 8)

              }

              if let area = country.area {

                HStack {
                  Text("Area:").bold().frame(alignment: .leading)
                  Text("\(formatNumber(num: area))") + Text(" km").font(.system(size: 16))
                    + Text("2")
                    .font(.system(size: 10))
                    .baselineOffset(8) + Text(" (Rank: \(country.areaRank ?? 0))").font(.system(size: 15))
                  Spacer()
                }.padding(.vertical, 8)
              }

              if let region = country.region {
                HStack {
                  Text("Region:").bold().frame(alignment: .leading)
                  Text(region)
                  Spacer()
                }.padding(.vertical, 8)
              }

              if let languages = country.languages {
                HStack {
                  Text("Languages:").bold().frame(alignment: .leading)
                  Text(languages.joined(separator: " ,"))
                  Spacer()
                }.padding(.vertical, 8)
              }
              HStack {
                Text("Population Density:").bold().frame(alignment: .leading)
                Text(formatNumber(num: country.populationDensity)) + Text(" / sq km")
                  + Text("2")
                  .font(.system(size: 10))
                  .baselineOffset(8) + Text(" (Rank: \(country.populationDensityRank ?? 0))").font(.system(size: 15))
                Spacer()
              }.padding(.vertical, 8)
                
               
                
                
                  

              }.padding(12)
          }

      }

    }

