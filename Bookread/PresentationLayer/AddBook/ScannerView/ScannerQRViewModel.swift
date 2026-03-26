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

enum DataScannerAccessStatutType {
    case notDetermine
    case cameraAccessNotGranted
    case cameraNotAvailable
    case scannerAvailable
    case scannerNotAvailable
}

@MainActor
final class ScannerQRViewModel: NSObject, ObservableObject {
    
    @Published var dataScannerAccessStatus: DataScannerAccessStatutType = .notDetermine
    
    @Published var textFromQr: String = ""
    @Published var showingImagePicker = false
    
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()
    
    override init() {
        super.init()
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
    
    func decodeAppQR(message: [String]) {
        
    }
    
    func decodeCustomQR(message: String) {
        
    }
}
