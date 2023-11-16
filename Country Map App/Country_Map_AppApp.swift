//
//  Country_Map_AppApp.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-11.
//

import SwiftUI
import SDWebImageSVGCoder

@main
struct Country_Map_AppApp: App {
    init() {
                setUpDependencies() // Initialize SVGCoder
            }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


// Initialize SVGCoder
private extension Country_Map_AppApp {
    
    func setUpDependencies() {
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
    }
}

