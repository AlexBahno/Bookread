//
//  FirebaseService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 22.02.2026.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

protocol FirebaseServiceProtocol {
    func setCurrentUser(_ user: User)
    func getCurrentUser() -> User?
    func getAuth() -> Auth
    func getStorage() -> Storage
    func getFirestore() -> Firestore
}

final class FirebaseService: FirebaseServiceProtocol {
    
    var currentUser: User?
    
    func setCurrentUser(_ user: User) {
        self.currentUser = user
    }
    
    func getCurrentUser() -> User? {
        return currentUser
    }
    
    func getAuth() -> Auth {
        return Auth.auth()
    }
    
    func getStorage() -> Storage {
        return Storage.storage()
    }
    
    func getFirestore() -> Firestore {
        return Firestore.firestore()
    }
}
