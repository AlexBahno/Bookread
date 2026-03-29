//
//  HomeMainView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 10.03.2026.
//

import SwiftUI

struct HomeMainView: View {
    
    @ObservedObject var viewModel: HomeMainViewModel
    
    var body: some View {
        container
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationTitle("Bookread")
            .navigationBarTitleDisplayMode(.inline)
    }
    
    var container: some View {
        ScrollView {
            VStack(spacing: .zero) {
                Text("Home")
            }
        }
    }
}
