//
//  FB_ReadingSessionService.swift
//  Bookread
//
//  Created by Alexandr Bahno on 02/06/2026.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

protocol FB_ReadingSessionServiceProtocol {
    
    func logReadingSession(
        session: ReadingSession,
        newTotalProgress: Int,
        isFinished: Bool
    ) async throws
    func bookSessionsStream(
        for bookId: String
    ) -> AsyncThrowingStream<[ReadingSession], Error>
    func recentActivityStream(
        for userId: String,
        limit: Int
    ) -> AsyncThrowingStream<[ReadingSession], Error>
}

final class FB_ReadingSessionService: FB_ReadingSessionServiceProtocol {
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    func logReadingSession(
        session: ReadingSession,
        newTotalProgress: Int,
        isFinished: Bool
    ) async throws {
        guard let uid = auth.currentUser?.uid else {
            throw NetworkError.unknown
        }
        
        let batch = firestore.batch()
        
        let sessionRef = firestore
            .collection("users")
            .document(uid)
            .collection("readingSessions")
            .document()
        
        let bookRef = firestore
            .collection("users")
            .document(uid)
            .collection("userBooks")
            .document(session.bookId)
        
        try batch.setData(from: session, forDocument: sessionRef)
        
        let newStatus: ReadingStatus = isFinished ? .finished : .reading
        let bookUpdates: [String: Any] = [
            "progress": newTotalProgress,
            "status": newStatus.rawValue,
            "lastReadAt": FieldValue.serverTimestamp(),
            "totalReadingSeconds": FieldValue.increment(Int64(session.durationInSeconds))
        ]
        batch.updateData(bookUpdates, forDocument: bookRef)
        
        try await batch.commit()
        
        print("✅ Session safely logged and book progress updated atomically.")
    }
    
    func bookSessionsStream(
        for bookId: String
    ) -> AsyncThrowingStream<[ReadingSession], Error> {
        AsyncThrowingStream { continuation in
            guard let uid = auth.currentUser?.uid else {
                continuation.finish(throwing: NetworkError.unknown)
                return
            }
            
            let query = firestore
                .collection("users")
                .document(uid)
                .collection("readingSessions")
                .whereField("bookId", isEqualTo: bookId)
                .order(by: "startTime", descending: true)
            
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.yield([])
                    return
                }
                
                let sessions = documents.compactMap { try? $0.data(as: ReadingSession.self) }
                continuation.yield(sessions)
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
                print("🛑 Firebase Book-Specific Session Listener safely removed.")
            }
        }
    }
    
    func recentActivityStream(
        for userId: String,
        limit: Int = 20
    ) -> AsyncThrowingStream<[ReadingSession], Error> {
        AsyncThrowingStream { continuation in
            let query = firestore
                .collection("users")
                .document(userId)
                .collection("readingSessions")
                .order(by: "startTime", descending: true)
                .limit(to: limit)
            let listener = query.addSnapshotListener { snapshot, error in
                if let error = error {
                    continuation.finish(throwing: error)
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    continuation.yield([])
                    return
                }
                
                let sessions = documents.compactMap { try? $0.data(as: ReadingSession.self) }
                continuation.yield(sessions)
            }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
                print("🛑 Firebase Recent Activity Listener safely removed for user: \(userId).")
            }
        }
    }
}
