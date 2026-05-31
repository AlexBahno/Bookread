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
    var currentUserId: String { get }
    var currentUser: AppUser? { get }
    
    var currentUserPublisher: AnyPublisher<AppUser?, Never> { get }
    
    func startSession(uid: String)
    func endSession()
}

@MainActor
final class SessionService: SessionServiceProtocol, ObservableObject {
    
    static let shared = SessionService()
    
    @Published var currentUserId: String = ""
    @Published var currentUser: AppUser?
    
    private let db = Firestore.firestore()
    private var listenerRegistration: ListenerRegistration?
    
    private init() {
        currentUserId = Auth.auth().currentUser?.uid ?? ""
    }
    
    // MARK: - Protocol Conformance for the Publisher
    var currentUserPublisher: AnyPublisher<AppUser?, Never> {
        $currentUser.eraseToAnyPublisher()
    }
    
    // MARK: - Session Management
    func startSession(uid: String) {
        currentUserId = uid
        listenerRegistration = db.collection("users").document(uid).addSnapshotListener { [weak self] documentSnapshot, error in
            guard let document = documentSnapshot, document.exists else {
                print("User document does not exist.")
                return
            }
            
            do {
                self?.currentUser = try document.data(as: AppUser.self)
            } catch {
                print("Error decoding user: \(error)")
            }
        }
    }
    
    func endSession() {
        listenerRegistration?.remove()
        currentUser = nil
    }
}
