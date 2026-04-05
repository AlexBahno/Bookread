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
            .onAppear {
                viewModel.startListening()
            }
            .onDisappear {
                viewModel.stopListening()
            }
    }
    
    var container: some View {
        ScrollView {
            VStack(spacing: 16.flexible()) {
                ForEach(viewModel.books) { book in
                    BookHomeCellView(book: book)
                        .onTapGesture {
                            viewModel.openBookView(with: book)
                        }
                }
            }
            .padding(.horizontal, 16.flexible())
            .padding(.bottom, 74.flexible())
        }
    }
}
