//
//  ProfileMainView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 21.03.2026.
//

import SwiftUI

struct ProfileMainView: View {
    
    @ObservedObject var viewModel: ProfileMainViewModel
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(viewModel.user?.username ?? "Profile")
            .toolbar {
                if viewModel.isPersonalAccount {
                    ToolbarItem(placement: .topBarTrailing) {
                        settingsButton
                    }
                }
            }
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: .zero) {
                header
                    .padding([.horizontal, .bottom], 16.flexible())
                
                if !viewModel.isPersonalAccount {
                    actionButton
                        .padding(.bottom, 16.flexible())
                }
                
                Divider()
                    .foregroundStyle(.gray666666)
                    .frame(height: 1.flexible())
                    .padding(.bottom, 16.flexible())
                
                HStack {
                    Text("Reading history")
                        .interRegular(size: 24.flexible())
                        .fontWeight(.medium)
                        .foregroundStyle(.text1A1A1A)
                    
                    Spacer()
                }
                .padding([.horizontal, .bottom], 16.flexible())
                
                
                VStack(spacing: 16.flexible()) {
                    HistoryReadingCell()
                    HistoryReadingCell()
                    HistoryReadingCell()
                    HistoryReadingCell()
                    HistoryReadingCell()
                    HistoryReadingCell()
                    HistoryReadingCell()
                    HistoryReadingCell()
                }
                .padding(.horizontal, 16.flexible())
                .padding(.bottom, 74.flexible())
            }
        }
    }
    
    var header: some View {
        VStack(spacing: .zero) {
            AsyncImage(url: viewModel.user?.imagePath) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
                    .shadow(radius: 2.flexible())
            } placeholder: {
                Circle()
                    .fill(.gray9E9E9E.opacity(0.65))
                    .shimmer()
            }
            .frame(width: 128.flexible(), height: 128.flexible())
            .padding(.bottom, 16.flexible())
            
            HStack(spacing: .zero) {
                getProfileStatistics(
                    amount: viewModel.user?.followerCount ?? 0,
                    title: "Followers"
                )
                Spacer()
                getProfileStatistics(
                    amount: viewModel.user?.followingCount ?? 0,
                    title: "Following"
                )
                Spacer()
                getProfileStatistics(
                    amount: 0,
                    title: "Has read"
                )
            }
        }
    }
    
    var actionButton: some View {
        AppStyleButton(text: "Subscribe", type: .withGreenBackground) {
            print("Subscribe")
        }
        .frame(width: UIScreen.screenWidth / 2)
    }
}

// MARK: - Helpers View
private extension ProfileMainView {
    
    var settingsButton: some View {
        Button {
            print("Setting")
        } label: {
            Image(systemName: "gearshape")
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(.text1A1A1A)
                .frame(width: 24.flexible(), height: 24.flexible())
        }
    }
}

// MARK: - Helpers Functions
private extension ProfileMainView {
    
    func getProfileStatistics(amount: Int, title: String) -> some View {
        VStack(spacing: .zero) {
            Text("\(amount)")
                .interRegular(size: 16.flexible())
                .foregroundStyle(.text1A1A1A)
            
            Text(title)
                .interRegular(size: 16.flexible())
                .foregroundStyle(.gray666666)
        }
    }
}
