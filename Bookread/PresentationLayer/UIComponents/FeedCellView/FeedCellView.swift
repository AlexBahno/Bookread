//
//  FeedCellView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29/05/2026.
//

import SwiftUI

struct FeedCellView: View {
    
    @ObservedObject var viewModel: FeedCellViewModel
    
    var body: some View {
        VStack(spacing: .zero) {
            userInfoStack
                .padding(.horizontal, 8.flexible())
                .padding(.vertical, 4.flexible())
                .background {
                    Rectangle()
                        .fill(.white)
                        .cornerRadius(16.flexible(), corners: [.topLeft, .topRight])
                        .shadow(radius: 2.flexible())
                }
            
            bookInfoStack
                .padding(.horizontal, 8.flexible())
                .padding(.vertical, 8.flexible())
                .background {
                    bookStackBackground
                        .frame(maxWidth: .infinity)
//                        .clipped()
                        .blur(radius: 40.flexible())
                        .clipped()
                }
            
            actionsStack
                .padding(.horizontal, 8.flexible())
                .padding(.vertical, 4.flexible())
                .background {
                    Rectangle()
                        .fill(.white)
                        .cornerRadius(16.flexible(), corners: [.bottomLeft, .bottomRight])
                        .shadow(radius: 2.flexible())
                }
        }
        
    }
    
    var userInfoStack: some View {
        HStack(spacing: .zero) {
            usersImage
                .frame(width: 48.flexible(), height: 48.flexible())
                .padding(.trailing, 4.flexible())
                .onTapGesture {
                    viewModel.openOwnersProfile()
                }
            
            VStack(alignment: .leading, spacing: 4.flexible()) {
                Text(viewModel.owner.username)
                    .interRegular(size: 16.flexible())
                    .fontWeight(.medium)
                    .foregroundStyle(.text1A1A1A)
                
                Text(viewModel.session.formattedTime)
                    .interRegular(size: 14.flexible())
                    .fontWeight(.light)
                    .foregroundStyle(.gray666666)
            }
            
            Spacer()
            
            Text(viewModel.session.dateString)
                .interRegular(size: 14.flexible())
                .foregroundStyle(.gray9E9E9E)
        }
    }
    
    var bookInfoStack: some View {
        HStack(spacing: 16.flexible()) {
            bookCoverImage
                .frame(width: 128.flexible(), height: 169.flexible())
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
            
            VStack(alignment: .leading, spacing: .zero) {
                Text(viewModel.session.bookTitle)
                    .interRegular(size: 18.flexible())
                    .fontWeight(.medium)
                    .foregroundStyle(.text1A1A1A)
                    .multilineTextAlignment(.leading)
                    .padding(.top, 8.flexible())
                    .padding(.bottom, 8.flexible())
                
                Text(viewModel.book.author)
                    .interRegular(size: 16.flexible())
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            
            Spacer(minLength: .zero)
        }
    }
    
    var actionsStack: some View {
        HStack(spacing: .zero) {
            Button {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                viewModel.toggleLike()
            } label: {
                HStack(spacing: 6.flexible()) {
                    Image(systemName: viewModel.isLiked ? "heart.fill" : "heart")
                        .font(.system(size: 20.flexible()))
                        .foregroundColor(viewModel.isLiked ? .red : .primary2D5F5D)
                        .scaleEffect(viewModel.isLiked ? 1.1 : 1.0)
                        .animation(
                            .spring(response: 0.3, dampingFraction: 0.5),
                            value: viewModel.isLiked
                        )
                    
                    Text("\(viewModel.session.likesCount)")
                        .interRegular(size: 18.flexible())
                        .foregroundColor(.text1A1A1A)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
        }
    }
}

// MARK: - Helpers
private extension FeedCellView {
    
    @ViewBuilder
    var usersImage: some View {
        if let imgURL = viewModel.owner.imagePath {
            AsyncImage(url: imgURL) { image in
                image
                    .resizable()
                    .scaledToFill()
                    .clipShape(Circle())
            } placeholder: {
                Circle()
                    .fill(.gray9E9E9E.opacity(0.65))
                    .shimmer()
            }
        } else {
            ZStack {
                Circle()
                    .fill(.gray9E9E9E.opacity(0.65))
                
                Image(systemName: "person.crop.circle")
                    .resizable()
                    .foregroundStyle(.text1A1A1A)
                    .scaledToFill()
                    .padding(8.flexible())
            }
        }
    }
    
    @ViewBuilder
    var bookCoverImage: some View {
        if let imgURL = viewModel.book.imgURL {
            AsyncImage(url: imgURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.gray9E9E9E.opacity(0.65))
                    .shimmer()
            }
        } else {
            Rectangle()
                .fill(.gray9E9E9E.opacity(0.8))
                .overlay(alignment: .center) {
                    VStack(spacing: 4.flexible()) {
                        Text(viewModel.session.bookTitle)
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.session.bookAuthor ?? "N/A")
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4.flexible())
                }
        }
    }
    
    @ViewBuilder
    var bookStackBackground: some View {
        if let imgURL = viewModel.book.imgURL {
            AsyncImage(url: imgURL) { image in
                image
                    .resizable()
                //                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.gray9E9E9E.opacity(0.65))
            }
        } else {
            Rectangle()
                .fill(.gray9E9E9E.opacity(0.65))
        }
    }
}
