//
//  Charts.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-18.
//

import SwiftUI
import Charts
import UIKit

struct STYLE  {
    static let BACKGROUND =  Color.gray.opacity(0.1)
}

enum CHART_STYLE{
    case sector
    case bar
    
}


// Pre-defined chart colors for data visualization. Source:chatGPT
let chartColors: [Color] = [
    Color(red: 255/255, green: 99/255, blue: 71/255),  // Tomato
    Color(red: 30/255, green: 144/255, blue: 255/255), // Dodger Blue
    Color(red: 255/255, green: 215/255, blue: 0/255),   // Gold
    Color(red: 255/255, green: 165/255, blue: 0/255),   // Orange
    Color(red: 0/255, green: 128/255, blue: 0/255),     // Green
    Color(red: 128/255, green: 0/255, blue: 128/255),   // Purple
    Color(red: 0/255, green: 0/255, blue: 128/255),     // Navy
    Color(red: 255/255, green: 69/255, blue: 0/255),    // Red-Orange
    Color(red: 255/255, green: 99/255, blue: 0/255),    // Dark Orange
    Color(red: 0/255, green: 0/255, blue: 255/255),     // Blue
    Color(red: 0/255, green: 255/255, blue: 0/255),     // Lime
    Color(red: 0/255, green: 128/255, blue: 128/255),   // Teal
    Color(red: 255/255, green: 182/255, blue: 193/255), // Light Pink
    Color(red: 218/255, green: 112/255, blue: 214/255), // Orchid
    Color(red: 255/255, green: 20/255, blue: 147/255),  // Deep Pink
    Color(red: 0/255, green: 255/255, blue: 255/255),   // Cyan
    Color(red: 255/255, green: 165/255, blue: 0/255),   // Orange
    Color(red: 128/255, green: 128/255, blue: 0/255),   // Olive
    Color(red: 0/255, green: 255/255, blue: 127/255),   // Spring Green
    Color(red: 255/255, green: 0/255, blue: 0/255)      // Red
]


// SwiftUI view for displaying various charts
struct ChartView: View {
    @ObservedObject var model: CountryViewModel
    var body: some View {
        // Check for different status to determine the view to display
        if (model.allCountriesStatus == .error){
            FetchErrorView()
        }
        
        if (model.allCountriesStatus == .loading){
            LoadingView()
        }
        
        
        if (model.allCountriesStatus == .idle){
            // Extract data for different chart sections
            let top10ByArea = model.areaStats
            let top10ByPopulation = model.populationStats
            let regionByPopulationStats = model.regionByPopulationStats
            let regionByLanguageCountStats = model.regionByLanguageCountStats
            let regionByCountryCountStats = model.regionByCountryCountStats
            
            // Display different chart sections using a list
            List{
                VStack(spacing: 32){
                    ChartSection(title: "Top 10 countries by population", data: top10ByPopulation,style: .sector)
                    ChartSection(title: "Top 10 countries by area", data: top10ByArea, style: .bar)
                    PieSection(title: "Regions by Population", data: regionByPopulationStats)
                    PieSection(title: "Regions by Language Count", data: regionByLanguageCountStats)
                    DefaultBarChart(title: "Regions by Country Count", data: regionByCountryCountStats)
                    
                }
            }.listStyle(PlainListStyle())
        }
        
    }
}

// SwiftUI view for displaying a pie chart section

struct PieSection: View {
  var title: String
  var data: [ChartData]


  @State var displayAnnotations: Bool = true
    
  var body: some View {
    ZStack {
      STYLE.BACKGROUND
      VStack {
        Text(title).bold()

      
          Chart {
            ForEach(data.indices, id: \.self) { index in
              let datum = data[index]

                SectorMark(angle: .value(title, datum.value),innerRadius: .ratio(0.6))
                .annotation(
                  position: .overlay, alignment: .center,
                  content: {
                    if displayAnnotations {
                        Text("\(datum.type) - \(formatNumber(num: datum.value, fraction:0))")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(y: -10)
                    }
                  }
                )
                .foregroundStyle(by: .value("Type", datum.type))
                .opacity(0.6)
                
            }
          }.onTapGesture {
            displayAnnotations.toggle()
          }
          .chartLegend(position: .top, alignment: .center, spacing: 10)

          .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/)
          .frame(idealHeight:  200)
          .padding(.horizontal, 24)
        
      }.padding(.vertical, 24)

    }

  }
}

// SwiftUI view for displaying a default bar chart section
struct DefaultBarChart: View {
  var title: String
  var data: [ChartData]

  @State var displayAnnotations: Bool = false
    
  var body: some View {
    ZStack {
      STYLE.BACKGROUND
      VStack {
        Text(title).bold()

       
            Chart {
              ForEach(data.indices, id: \.self) { index in
                let datum = data[index]
                      
                  BarMark(x: .value(title, datum.value) , y: .value(title,
                                                                           "\(datum.id)"))
                  .annotation(
                    position: .overlay, alignment: .center,
                    content: {
                      if displayAnnotations {
                          Text("\(formatNumber(num:datum.value, fraction:0))")
                          .font(.footnote)
                          .foregroundColor(.white)
                          .padding(4)
                          .background(Color.black.opacity(0.7))
                          .clipShape(RoundedRectangle(cornerRadius: 8))
                          .offset(y: -10)
                      }
                    }
                  )
                  .foregroundStyle( chartColors[index % chartColors.count])
                  .opacity(0.8)
                            
              }
            }.onTapGesture {
                displayAnnotations.toggle()
              }
            .chartLegend(position: .top, alignment: .top)
            .frame(maxWidth: .infinity, idealHeight:  800)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
           
        }
      }.padding(.vertical, 24)

    

  }
}



struct ChartSection: View {
  var title: String
  var data: [ChartData]
  var style: CHART_STYLE

  @State var displayAnnotations: Bool = false
    

    

  var body: some View {
    ZStack {
      STYLE.BACKGROUND
      VStack {
        Text(title).bold()

        if style == .sector {
          Chart {
            ForEach(data.indices, id: \.self) { index in
              let datum = data[index]

              SectorMark(angle: .value(title, datum.value))
                .annotation(
                  position: .overlay, alignment: .center,
                  content: {
                    if displayAnnotations {
                      Text("\(datum.type)")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.black.opacity(0.7))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .offset(y: -10)
                    }
                  }
                )
                .foregroundStyle(by: .value("Type", datum.type))
                .opacity(0.6)
            }
          }.onTapGesture {
            displayAnnotations.toggle()
          }
          .chartLegend(position: .top, alignment: .center, spacing: 10)

          .frame(maxWidth: /*@START_MENU_TOKEN@*/ .infinity /*@END_MENU_TOKEN@*/)
          .frame(idealHeight:  200)
          .padding(.horizontal, 24)
        }else if (style == .bar){
            Chart {
              ForEach(data.indices, id: \.self) { index in
                  
                let datum = data[index]
                  let roundedArea = formatNumber(num: datum.value / 1000, fraction: 0)

                  BarMark(x: .value(title, datum.value / 1000) , y: .value(title,
                                                                           "\(datum.id) - \(roundedArea) km/sq"))
                  .foregroundStyle( chartColors[index % chartColors.count])
                  .opacity(0.8)
                            
              }
            }
            .chartLegend(position: .top, alignment: .top)
            .frame(maxWidth: .infinity, idealHeight:  800)
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
           
        }
      }.padding(.vertical, 24)

    }

  }
}
