//
//  CountryListItemView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-19.
//

import SwiftUI
import SDWebImageSVGCoder
import SDWebImageSwiftUI

// MARK: CountryListItemView

struct CountryListItemView: View {
    // The country to display
    var country: Country
    
    // Index of the country in the list
    var index: Int
    
    // Total population and area for percentage calculations
    var totalPopulation: Double
    var totalArea: Double
    
    // Callback to handle favorite status change
    var handleFavoriteChange: (_ name: String) -> Void
    
    // State variable to manage sheet presentation
    @State private var isSheetPresented = false

    var body: some View {
        VStack {
            HStack {
                // Display country rank
                Text("\(index+1)")
                
                // Display country flag

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
                
                // Display country name
                Text(country.name.trimmingCharacters(in: .whitespacesAndNewlines))
                    .font(.headline)
                
                Spacer()
                
                // Display favorite status and handle taps
                if let favorited = country.favorited {
                    Image(systemName: favorited ? IMAGE_NAMES.FAVORITED : IMAGE_NAMES.NOT_FAVORITED)
                        .foregroundColor(.yellow)
                        .padding(.trailing, 4)
                        .onTapGesture {
                            handleFavoriteChange(country.name)
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
            .cornerRadius(10)
            .shadow(radius: 2)
            .padding(.vertical, 2)
        }
        .onTapGesture {
            // Show country details when tapped
            isSheetPresented = true
        }
        .sheet(isPresented: $isSheetPresented) {
            // Present a sheet with detailed information when isSheetPresented is true
            CountrySheetView(country: country, 
                             totalPopulation: totalPopulation,
                             totalArea: totalArea,
                             isSheetPresented: $isSheetPresented,
                             toggleFavorite: handleFavoriteChange)
        }
    }
}
