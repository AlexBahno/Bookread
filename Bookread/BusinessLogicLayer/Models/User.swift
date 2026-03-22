//
//  User.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.02.2026.
//

import Foundation

struct AppUser: Identifiable, Decodable {
    private var uid: String
    var username: String
    var email: String
    private var profileImageUrl: String?
    var followerCount: Int
    var followingCount: Int
    
    init() {
        self.uid = ""
        self.username = ""
        self.email = ""
        self.profileImageUrl = nil
        self.followerCount = 0
        self.followingCount = 0
    }
    
    init(
        id: String,
        username: String,
        email: String,
        imagePath: String?,
        followerCount: Int,
        followingCount: Int
    ) {
        self.uid = id
        self.username = username
        self.email = email
        self.profileImageUrl = imagePath
        self.followerCount = followerCount
        self.followingCount = followingCount
    }
    
    var id: String {
        return uid
    }
    
    var imagePath: URL? {
        if let profileImageUrl {
            return URL(string: profileImageUrl)
        }
        return nil
    }
}
