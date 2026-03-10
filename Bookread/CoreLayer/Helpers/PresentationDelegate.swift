//
//  PresentationDelegate.swift
//  Bookread
//
//  Created by Alexandr Bahno on 17.02.2026.
//

import UIKit

final class PresentationDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    
    private let onInteractiveDismiss: () -> Void
    
    init(onInteractiveDismiss: @escaping () -> Void) {
        self.onInteractiveDismiss = onInteractiveDismiss
    }
    
    func presentationControllerDidDismiss(
        _ presentationController: UIPresentationController
    ) {
        print("PresentedViewController was dismissed interactively by swipe down")
        onInteractiveDismiss()
    }
}
