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
        
        // https://github.com/SDWebImage/SDWebImageSwiftUI - "Customization and configuration setup"
        let cache = SDImageCache(namespace: "tiny")
        cache.config.maxMemoryCost = 100 * 1024 * 1024 // 100MB memory
        cache.config.maxDiskSize = 50 * 1024 * 1024 // 50MB disk
        SDImageCachesManager.shared.addCache(cache)
        SDWebImageManager.defaultImageCache = SDImageCachesManager.shared


    }
}

