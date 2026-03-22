//
//  SessionService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 21.03.2026.
//

import Combine
import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol SessionServiceProtocol {
    var currentUser: AppUser? { get }
    
    var currentUserPublisher: AnyPublisher<AppUser?, Never> { get }
    
    func startSession(uid: String)
    func endSession()
}

@MainActor
final class SessionService: SessionServiceProtocol, ObservableObject {
    
    static let shared = SessionService()
    
    @Published var currentUser: AppUser?
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    private init() {}
    
    // MARK: - Protocol Conformance for the Publisher
    var currentUserPublisher: AnyPublisher<AppUser?, Never> {
        $currentUser.eraseToAnyPublisher()
    }
    
    // MARK: - Session Management
    func startSession(uid: String) {
        // Attach a real-time listener to this specific user's document
        listenerRegistration = db.collection("users").document(uid).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                print("User document does not exist.")
                return
            }
            
            do {
                // Instantly update the global cache!
                self?.currentUser = try document.data(as: AppUser.self)
            } catch {
                print("Error decoding user: \(error)")
            }
        }
    }
    
    func endSession() {
        // Critical for preventing memory leaks when they log out
        listenerRegistration?.remove()
        currentUser = nil
    }
}
