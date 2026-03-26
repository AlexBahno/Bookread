// swiftlint: disable force_unwrapping force_cast
//  QRScannerController.swift
//  QRCraft
//
//  Created by Alexandr Bahno on 25.06.2025.
//

import UIKit
import SwiftUI
import AVFoundation

extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
}

final class QRScannerController: UIViewController {
    
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    var result: ((String) -> Void)?
    
    func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = .zero
            return
        }
        
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == .ean13 {
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if let text = metadataObj.stringValue {
                result?(text)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(input)
            
            let captureMetaDataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetaDataOutput)
            
            captureMetaDataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetaDataOutput.metadataObjectTypes = [.ean13]
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = .resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            
            view.layer.addSublayer(videoPreviewLayer!)
            
            startScanning()
            
            qrCodeFrameView = UIHostingController(rootView: CornerShape()).view
            
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.backgroundColor = .clear
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
        } catch {
            print(error)
            return
        }
    }
    
    func startScanning() {
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    func stopScanning() {
        self.qrCodeFrameView?.frame = .zero
        DispatchQueue.global().async {
            self.captureSession.stopRunning()
        }
    }
}
