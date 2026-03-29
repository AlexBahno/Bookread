//
//  ScannerQRViewModel.swift
//  Bookread
//
//  Created by Alexandr Bahno on 24.03.2026.
//

import AVKit
import VisionKit
import CoreImage.CIFilterBuiltins
import UIKit
import NetworkExtension
import CoreLocation
import MapKit
import Photos
import Combine
import Alamofire
import SwiftUI

struct ScannerViewRouter {
    let goBackToMain: () -> Void
}

enum DataScannerAccessStatutType {
    case notDetermine
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class ScannerQRViewModel: ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatutType = .notDetermine
    
    @Published var textFromQr: String = ""
    @Published var showingImagePicker = false
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    private let networkService: NetworkProtocol
    private let router: ScannerViewRouter
    
    init(networkService: NetworkProtocol, router: ScannerViewRouter) {
        self.networkService = networkService
        self.router = router
    }
    
    func requestDataScannerAccessStatus() async {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            dataScannerAccessStatus = .cameraNotAvailable
            return
        }
        
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            dataScannerAccessStatus = .scannerAvailable
            
        case .restricted, .denied:
            dataScannerAccessStatus = .cameraAccessNotGranted
            
        case .notDetermined:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            if granted {
                dataScannerAccessStatus = .scannerAvailable
            } else {
                dataScannerAccessStatus = .cameraAccessNotGranted
            }
            
        default:
            break
        }
    }
    
    func goBack() {
        router.goBackToMain()
        openSheetWithScannedBook()
    }
    
    private func openSheetWithScannedBook() {
        Task {
            do {
                let book = try await makeRequest()
                UIApplication.shared.presentGlobalSheet {
                    FoundedBookSheet(bookWrapper: book)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    @MainActor
    private func makeRequest() async throws -> Book {
        let request = Request(
            path: "",
            method: .get,
            parameters: [
                "q": "isbn:\(textFromQr)",
                "key": NetworkConstants.booksQueryKey,
                "maxResults": "1"
            ]
        )
        
        do {
            let response: Books = try await networkService.executeWithCodable(request: request)
            
            if let book = response.books?.first {
                return book
            } else {
                throw NetworkError.unknown
            }
        } catch {
            throw error
        }
    }
}
