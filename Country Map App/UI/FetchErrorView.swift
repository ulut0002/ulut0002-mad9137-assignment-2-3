//
//  FetchErrorView.swift
//  Country Map App
//
//  Created by Serdar Ulutas on 2023-11-19.
//

import SwiftUI

// MARK: - FetchErrorView


struct FetchErrorView: View {
    var body: some View {
        // Vertical stack to organize the content
        VStack{
            Spacer() // Spacer for pushing the content to the top of the screen
            
            // Display an error icon using the system symbol
            Image(systemName: IMAGE_NAMES.FETCH_ERROR_VIEW)
                .font(.system(size: 100))
                .padding(.vertical, 10)
                .foregroundColor(Color.red)
            
            // Display an error message indicating that data retrieval failed
            Text("Fetch error. Data could not be retrieved")
                .font(.title2)
                .multilineTextAlignment(.center)
            
             
            Spacer() // Spacer for pushing the content to the bottom of the screen
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    FetchErrorView()
}
