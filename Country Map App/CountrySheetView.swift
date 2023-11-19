//
//  CountrySheetView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-18.
//

import SwiftUI
import SDWebImageSVGCoder
import SDWebImageSwiftUI


struct CountrySheetView: View {
    var country: Country
    var totalPopulation: Double
    var totalArea: Double
    @Binding var isSheetPresented: Bool
    var toggleFavorite: (_ name: String) -> Void
    

    
  

    
  var body: some View {

      ZStack(alignment: .top) {

          LinearGradient(gradient: Gradient(colors: [Constants.COLOR_BLUE_1, Constants.COLOR_BLUE_2]), startPoint: .topLeading, endPoint: .bottomTrailing).ignoresSafeArea(.all)
          
          VStack(alignment: .center) {
              HStack(alignment: .center){
               
                      Button("", systemImage:"chevron.compact.down"){
                          isSheetPresented = false
                      }.font(.title)
                      .padding(0)
                  
                  Spacer()
                  Text(country.name)
                      .font(.headline)
                      .multilineTextAlignment(.center)
                      
                  Spacer()
                  Menu("", systemImage: "ellipsis"){
                      if let favorited = country.favorited {
                          if (favorited){
                              Button("Remove from Favorites"){
                                  toggleFavorite(country.id)
                              }
                          }else{
                                  Button("Add to Favorites"){
                                      toggleFavorite(country.id)
                                  }
                              
                          }
                      }
                      
                  }.font(.title)
                      .padding(0)
              }.padding(8)
              
              Spacer()
        
         
              VStack(alignment: .center){
                       
                      if let flag = country.flag {
                          WebImage(
                            url: URL(string: flag), options: [],
                            context: [.imageThumbnailPixelSize: CGSize.zero]
                          )
                          .placeholder { ProgressView().frame(width: 12, height: 12) }
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(maxWidth: 300, idealHeight: .infinity, alignment: .center)
                          .cornerRadius(20)
                      }
                 
                   

                      
                          
                  VStack(alignment: .leading){
                      
                      ZStack{
                         
                          VStack(alignment: .leading){
                              if let capital = country.capital {
                                  HStack(alignment: .top) {
                                      Text("Capital City:").bold().frame(alignment: .leading)
                                      Text(capital)
                                      
                                  }.padding(.vertical, 8)
                              }
                              
                              if let population = country.population {
                                  
                                  HStack(alignment: .top) {
                                      Text("Population:").bold().frame(alignment: .leading)
                                      Text(formatNumber(num: population))+Text(" people") +  Text(" (Rank: \(country.populationRank ?? 0))").font(.system(size: 15))
                                  }.padding(.vertical, 8)
                                  
                              }
                              
                              if let area = country.area {
                                  
                                  HStack(alignment: .top) {
                                      Text("Area:").bold().frame(alignment: .leading)
                                      Text("\(formatNumber(num: area))") + Text(" km").font(.system(size: 16))
                                      + Text("2")
                                          .font(.system(size: 10))
                                          .baselineOffset(8) + Text(" (Rank: \(country.areaRank ?? 0))").font(.system(size: 15))
                                      
                                  }.padding(.vertical, 8)
                              }
                              
                              if let region = country.region {
                                  HStack(alignment: .top) {
                                      Text("Region:").bold().frame(alignment: .leading)
                                      Text(region)
                                      
                                  }.padding(.vertical, 8)
                              }
                              
                              if let languages = country.languages {
                                  HStack(alignment: .top) {
                                      Text("Languages:").bold().frame(alignment: .leading)
                                      Text(languages.joined(separator: ", "))
                                      
                                  }.padding(.vertical, 8)
                              }
                              HStack(alignment: .top) {
                                  Text("Population Density:").bold().frame(alignment: .leading)
                                  Text(formatNumber(num: country.populationDensity)) + Text(" / sq km")
                                  + Text("2")
                                      .font(.system(size: 10))
                                      .baselineOffset(8) + Text(" (Rank: \(country.populationDensityRank ?? 0))").font(.system(size: 15))
                                  
                              }.padding(.vertical, 8)
                          } //end of VSTACK
                      }
                  }
      
                     
              }.padding(.vertical, 32)
              Spacer()
        

          }.padding(8)
        
      }

  }

}

