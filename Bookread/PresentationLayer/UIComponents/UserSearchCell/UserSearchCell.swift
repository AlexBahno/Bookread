//
//  UserSearchCell.swift
//  Bookread
//
//  Created by Alexandr Bahno on 31/05/2026.
//

import SwiftUI

struct UserSearchCell: View {
    
    let user: AppUser
    let openProfile: (AppUser) -> Void
    
    var body: some View {
        HStack(spacing: .zero) {
            usersImage
                .frame(width: 48.flexible(), height: 48.flexible())
                .padding(.trailing, 8.flexible())
            
            Text(user.username)
                .interRegular(size: 18.flexible())
                .fontWeight(.medium)
                .foregroundStyle(.text1A1A1A)
            
            Spacer()
        }
        .onTapGesture {
            openProfile(user)
        }
    }
    
    @ViewBuilder
    var usersImage: some View {
        if let imgURL = user.imagePath {
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
}
