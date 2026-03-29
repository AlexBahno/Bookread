import SwiftUI
import Photos

struct ScannerQRMainView: View {
    
    @ObservedObject var viewModel: ScannerQRViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            switch viewModel.dataScannerAccessStatus {
            case .scannerAvailable: container
            case .cameraAccessNotGranted: settingsView
            default: EmptyView()
            }
        }
        .background(.backgroundFAFAF8)
        .task {
            await viewModel.requestDataScannerAccessStatus()
        }
        .onAppear {
            TabBarManager.shared.hide()
        }
        .onDisappear() {
            TabBarManager.shared.show()
        }
    }
    
    var container: some View {
        DataScannerView(isResultViewAppear: false)
            .ignoresSafeArea()
            .environmentObject(viewModel)
    }
    
    var settingsView: some View {
        VStack(spacing: 40.flexible()) {
            Text("Please tap the “Open Settings” button to allow access.")
                .interRegular(size: 24.flexible())
                .fontWeight(.semibold)
                .foregroundStyle(.text1A1A1A)
                .multilineTextAlignment(.center)
            
            AppStyleButton(
                text: "Open Settings",
                image: Image(systemName: "gearshape.fill"),
                type: .withGreenBackground
            ) {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString),
                   UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
        }
        .padding(.horizontal, 16.flexible())
    }
}
