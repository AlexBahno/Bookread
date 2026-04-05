//
//  SearchMainView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 24.03.2026.
//

import SwiftUI

struct SearchView: View {
    
    @ObservedObject var viewModel: SearchViewModel
    
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Add Book")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    scannerButton
                }
            }
            .onAppear {
                viewModel.startObserve()
            }
            .animation(.easeInOut, value: viewModel.state)
    }
    
    var content: some View {
        VStack(spacing: .zero) {
            CustomSearchField(
                placeholder: "Search for book by title",
                text: $viewModel.searchText
            ) {
                self.viewModel.searchText = ""
            }
            .focused($isSearchFieldFocused)
            .padding([.horizontal], 16.flexible())
            
            switch viewModel.state {
            case .idle:
                Spacer()
                
                EmptyStateView(
                    image: "magnifyingglass",
                    title: "Start to search books"
                )
                
                Spacer()
            case .empty:
                Spacer()
                
                EmptyStateView(
                    image: "book.fill",
                    title: "We were not able to find book with this title.\nTry to scan barcode"
                )
                
                Spacer()
            case .loading:
                Spacer()
                
                ProgressView("Loading...")
                    .foregroundStyle(.primary2D5F5D)
                
                Spacer()
            case .failed:
                Spacer()
                
                FailedStateView(
                    mainText: "Something went wromg",
                    description: viewModel.error?.localizedDescription ?? "Error has occured"
                ) {
                }
                
                Spacer()
            case .success:
                resultView
            }
        }
    }
    
    var resultView: some View {
        ScrollView {
            VStack(spacing: 16.flexible()) {
                ForEach(viewModel.result) { book in
                    BookCellView(bookWrapper: book)
                        .onTapGesture {
                            viewModel.openBookView(book.userBook)
                        }
                }
            }
            .padding(.top, 16.flexible())
            .padding(.horizontal, 16.flexible())
            .padding(.bottom, 74.flexible())
        }
    }
}

// MARK: - Helpers View
private extension SearchView {
    
    var scannerButton: some View {
        Button {
            viewModel.openScannerView()
        } label: {
            Image(systemName: "camera.fill")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.text1A1A1A)
                .scaledToFit()
                .frame(width: 24.flexible(), height: 24.flexible())
        }
    }
}
