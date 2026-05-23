//
//  User.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.02.2026.
//

import Foundation
import UIKit

final class AppUserImageCache {
    static let shared = AppUserImageCache()
    private let cache = NSCache<NSURL, UIImage>()
    private init() {}

    func image(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    func insert(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

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
    
    // MARK: - Async image loading
    /// Loads the user's profile image asynchronously. Returns nil if no URL is set or the request fails.
    func loadImage() async -> UIImage? {
        guard let url = imagePath else { return nil }
        if let cached = AppUserImageCache.shared.image(for: url) { return cached }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                AppUserImageCache.shared.insert(image, for: url)
                return image
            }
        } catch {
            print("Failed to load image async: \(error.localizedDescription)")
        }
        return nil
    }

    /// Loads the user's profile image asynchronously using a completion handler for callers not using async/await.
    func loadImage(completion: @escaping (UIImage?) -> Void) {
        guard let url = imagePath else { completion(nil); return }
        if let cached = AppUserImageCache.shared.image(for: url) { completion(cached); return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Failed to load image async (callback): \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            if let data = data, let image = UIImage(data: data) {
                AppUserImageCache.shared.insert(image, for: url)
                DispatchQueue.main.async { completion(image) }
            } else {
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}
