//
//  DataScannerView.swift
//  QRCraft
//
//  Created by Alexandr Bahno on 24.06.2025.
//

import SwiftUI
import VisionKit

struct DataScannerView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = QRScannerController
    
    @EnvironmentObject var viewModel: ScannerQRViewModel
    let isResultViewAppear: Bool
    
    func makeUIViewController(context: Context) -> QRScannerController {
        let viewController = QRScannerController()
        viewController.result = { result in
            DispatchQueue.main.async {
                viewModel.textFromQr = result
                viewController.stopScanning()
                viewModel.goBack()
            }
        }
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {
        if isResultViewAppear {
            uiViewController.stopScanning()
        } else {
            uiViewController.startScanning()
        }
    }
    
    static func dismantleUIViewController(
        _ uiViewController: QRScannerController,
        coordinator: ()
    ) {
        uiViewController.stopScanning()
    }
}
