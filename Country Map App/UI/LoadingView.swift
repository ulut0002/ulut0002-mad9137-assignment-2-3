//
//  LoadingView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-19.
//

import SwiftUI

// MARK: - LoadingView

struct LoadingView: View {
    // Vertical stack to organize the content
    var body: some View {
        VStack{
            Spacer() // Spacer for pushing the content to the top of the screen
            
            // Display a loading spinner (ProgressView) with padding
            ProgressView().padding(16)
            
            // Display a text message indicating the loading process
            Text("Loading.. Please wait")
            
            Spacer() // Spacer for pushing the content to the bottom of the screen
        }
    }
}

#Preview {
    LoadingView()
}
