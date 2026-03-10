//
//  HomeMainView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 10.03.2026.
//

import SwiftUI

struct HomeMainView: View {
    
    var logout: (() -> Void)?
    
    var body: some View {
        ZStack {
            Color.accentC17767
                .ignoresSafeArea()
            
            Button("Log out") {
                logout?()
            }
        }
    }
}
