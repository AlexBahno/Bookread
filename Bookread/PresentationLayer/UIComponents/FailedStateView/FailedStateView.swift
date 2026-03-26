//
//  FailedStateView.swift
//  CityWeather
//
//  Created by Alexandr Bahno on 15.03.2026.
//

import SwiftUI

struct FailedStateView: View {
    
    let mainText: String
    let description: String
    var action: (() -> Void)?
    
    var body: some View {
        VStack {
            Text(mainText)
                .font(.headline)
            Text(description)
                .foregroundColor(.secondary)
            
            if let action {
                Button("Try Again") {
                    action()
                }
                .padding()
            }
        }
    }
}
