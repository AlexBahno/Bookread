//
//  FeedMainView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29/05/2026.
//

import SwiftUI

struct FeedMainView: View {
    
    @ObservedObject var viewModel: FeedMainViewModel
    @FocusState private var isSearchFieldFocused: Bool
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("For you")
            .onAppear {
                viewModel.setupSearchDebounce()
            }
            .task {
                viewModel.loadFeed()
            }
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black
                            .opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
//            .onChange(of: isSearchFieldFocused) { _, _ in
//                if isSearchFieldFocused || !viewModel.searchResult.isEmpty {
//                    TabBarManager.shared.hide()
//                } else {
//                    TabBarManager.shared.show()
//                }
//            }
    }
    
    @ViewBuilder
    var content: some View {
        VStack(spacing: .zero) {
            searchField
                .padding(.horizontal, 16.flexible())
            if isSearchFieldFocused {
                searchResultView
                    .padding(.top, 16.flexible())
            } else {
                if viewModel.feed.isEmpty, !viewModel.isLoading {
                    emptyFeed
                        .refreshable {
                            viewModel.loadFeed()
                        }
                } else {
                    feedView
                        .padding(.top, 16.flexible())
                }
            }
        }
    }
    
    var searchResultView: some View {
        ScrollView {
            VStack(spacing: 4.flexible()) {
                ForEach(viewModel.searchResult) { user in
                    UserSearchCell(user: user) { user in
                        viewModel.openProfilePage(user: user)
                    }
                }
            }
            .padding(.horizontal, 16.flexible())
        }
    }
    
    var feedView: some View {
        ScrollView {
            VStack(spacing: 8.flexible()) {
                ForEach(viewModel.feed) { feedItem in
                    FeedCellView(viewModel: .init(
                        feedItem: feedItem,
                        feedService: viewModel.feedService,
                        sessionService: viewModel.sessionsService,
                        openProfile: { user in
                            viewModel.openProfilePage(user: user)
                        }
                    ))
                }
            }
            .padding(.top, 4.flexible())
            .padding(.horizontal, 16.flexible())
            .padding(.bottom, 74.flexible())
        }
        .refreshable {
            viewModel.loadFeed()
        }
    }
    
    var emptyFeed: some View {
        ZStack(alignment: .top) {
            EmptyStateView(
                image: "person.fill.badge.plus",
                title: "Start to follow somebody to see his activities\nOr tap to reload your feed"
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onTapGesture {
                viewModel.loadFeed()
            }
        }
        .padding(.horizontal, 16.flexible())
    }
    
    var searchField: some View {
        CustomSearchField(
            placeholder: "Search users",
            text: $viewModel.searchQuery
        ) {
            self.viewModel.searchQuery = ""
        }
        .focused($isSearchFieldFocused)
    }
}
