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
    
    @ViewBuilder
    var container: some View {
        if viewModel.books.isEmpty {
            VStack(spacing: .zero) {
                EmptyStateView(
                    image: "text.book.closed.fill",
                    title: "There arent any books in your library"
                )
            }
        } else {
            ScrollView {
                VStack(spacing: 16.flexible()) {
                    if !viewModel.inProgressBooks.isEmpty {
                        VStack(spacing: 8.flexible()) {
                            HStack {
                                Text("In progress: \(viewModel.inProgressBooks.count)")
                                    .interRegular(size: 14.flexible())
                                    .foregroundStyle(.text1A1A1A)
                                
                                Spacer()
                            }
                            ForEach(viewModel.inProgressBooks) { book in
                                BookHomeCellView(book: book)
                                    .onTapGesture {
                                        viewModel.openBookView(with: book)
                                    }
                            }
                        }
                    }
                   
                    if !viewModel.finishedBooks.isEmpty {
                        VStack(spacing: 8.flexible()) {
                            HStack {
                                Text("Finished: \(viewModel.finishedBooks.count)")
                                    .interRegular(size: 14.flexible())
                                    .foregroundStyle(.text1A1A1A)
                                
                                Spacer()
                            }
                            ForEach(viewModel.finishedBooks) { book in
                                BookHomeCellView(book: book)
                                    .onTapGesture {
                                        viewModel.openBookView(with: book)
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal, 16.flexible())
                .padding(.bottom, 74.flexible())
            }
        }
    }
}
