//
//  CountrySheetView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-18.
//
// SVG Image: https://stackoverflow.com/questions/73100626/uploading-svg-images-to-swiftui/73401775#73401775
//

import SwiftUI
import SDWebImageSVGCoder
import SDWebImageSwiftUI

// MARK: - CountrySheetView

struct CountrySheetView: View {
    var country: Country
    var totalPopulation: Double
    var totalArea: Double
    @Binding var isSheetPresented: Bool
    var toggleFavorite: (_ name: String) -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(gradient: Gradient(colors: [CONSTANTS.SHEET_GRADIENT_COLOR_1, CONSTANTS.SHEET_GRADIENT_COLOR_2]), 
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea(.all)
     
            
            // Content View
            VStack(alignment: .center) {
                CountrySheetHeaderView(country: country, isSheetPresented: $isSheetPresented, toggleFavorite: toggleFavorite)
                CountrySheetDetailView(country: country)
            }.padding(.vertical, 0)
            Spacer()
        }
    }
}


// MARK: - CountrySheetHeaderView
struct CountrySheetHeaderView: View {

    var country: Country
    @Binding var isSheetPresented: Bool
    var toggleFavorite: (_ name: String) -> Void
    
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        HStack(alignment: .center){
            // Close Button
            Button("", systemImage:IMAGE_NAMES.CLOSE_SHEET){
                isSheetPresented = false
            }.font(.caption)
                .padding(0)
                .foregroundColor(colorScheme == .light ? Color.black : Color.white)
            
            
            Spacer()
            
            // Country Title
            Text(country.name)
                .font(country.name.count >= 20 ? .headline : .title2)
                .multilineTextAlignment(.center).kerning(1.3)
            
            Spacer()
            
            // Menu Button
            Menu("", systemImage: IMAGE_NAMES.MENU){
                if let favorited = country.favorited {
                    Button(favorited ? "Remove from Favorites" :"Add to Favorites"){
                        toggleFavorite(country.id)
                    }
                }
                
            }.padding(0)
                .foregroundColor(colorScheme == .light ? Color.black : Color.white)
        }.padding(.horizontal, 24).padding(.vertical, 16)
    }
}

// MARK: - CountrySheetDetailView
struct CountrySheetDetailView: View {
    var country: Country
    var body: some View {
        VStack(alignment: .center){
            // Country Flag
            if let flag = country.flag {
                WebImage(url: URL(string: flag), options: [],context: [.imageThumbnailPixelSize: CGSize.zero])
                    .placeholder {
                        ProgressView().frame(width: 12, height: 12)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 300, idealHeight: .infinity, alignment: .center)
                    .cornerRadius(20)
            }
            
            // Detail Information
            VStack(alignment: .leading){
                
                // Display Capital
                if let capital = country.capital {
                    HStack(alignment: .top) {
                        Text("Capital City:").bold().frame(alignment: .leading)
                        Text(capital)
                    }.padding(.vertical, 8)
                }
                
                // Display population and global rank
                if let population = country.population {
                    HStack(alignment: .top) {
                        Text("Population:").bold().frame(alignment: .leading)
                        Text("\(formatNumber(num: population)) people (Rank: \(country.populationRank ?? 0))")
                            .font(.system(size: 15))
                    }.padding(.vertical, 8)
                }
                
                // Display area size and global rank
                if let area = country.area {
                    HStack(alignment: .top) {
                        Text("Area:").bold().frame(alignment: .leading)
                        Text("\(formatNumber(num: area))") + Text(" km").font(.system(size: 16)) + Text("2")
                            .font(.system(size: 10))
                            .baselineOffset(8) +
                        Text(" (Rank: \(country.areaRank ?? 0))").font(.system(size: 15))
                    }.padding(.vertical, 8)
                }
                
                // Display region (continent)
                if let region = country.region {
                    HStack(alignment: .top) {
                        Text("Region:").bold().frame(alignment: .leading)
                        Text(region)
                    }.padding(.vertical, 8)
                }
                
                
                // Display languages
                if let languages = country.languages {
                    HStack(alignment: .top) {
                        Text("Languages:").bold().frame(alignment: .leading)
                        Text(languages.joined(separator: ", "))
                    }.padding(.vertical, 8)
                }
                
                // Display population density
                HStack(alignment: .top) {
                    Text("Population Density:").bold().frame(alignment: .leading)
                    Text(formatNumber(num: country.populationDensity)) +
                    Text(" / sq km") +
                    Text("2")
                        .font(.system(size: 10))
                        .baselineOffset(8) +
                    Text(" (Rank: \(country.populationDensityRank ?? 0))").font(.system(size: 15))
                }.padding(.vertical, 8)
            } //end of VSTACK
        }
    }
}
