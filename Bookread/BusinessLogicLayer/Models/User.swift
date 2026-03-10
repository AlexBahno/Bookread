//
//  User.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.02.2026.
//

import Foundation

struct User: Identifiable, Decodable {
    var id: String
    var username: String
    var email: String
    var imagePath: String?
    var followerCount: Int
    var followingCount: Int
    
    init() {
        self.id = ""
        self.username = ""
        self.email = ""
        self.imagePath = nil
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
        self.id = id
        self.username = username
        self.email = email
        self.imagePath = imagePath
        self.followerCount = followerCount
        self.followingCount = followingCount
    }
}
