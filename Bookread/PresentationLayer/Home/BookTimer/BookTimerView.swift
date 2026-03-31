//
//  BookTimerView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 29.03.2026.
//

import SwiftUI

struct BookTimerView: View {
    
    @ObservedObject var viewModel: BookTimerViewModel
    
    var body: some View {
        container
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationTitle("Bookread")
            .navigationBarTitleDisplayMode(.inline)
            .animation(.easeInOut, value: viewModel.currentState)
            .task {
                await viewModel.fetchBook()
            }
    }
    
    var container: some View {
        ScrollView {
            VStack(spacing: .zero) {
                coverImgAndTimer
                    .padding(.horizontal, 16.flexible())
                    .padding(.bottom, 16.flexible())
                
                actionButtons
                
                if viewModel.book.status != .none {
                    progressStack
                        .padding(.horizontal, 16.flexible())
                }
                
                sessionHistory
            }
        }
    }
    
    var coverImgAndTimer: some View {
        HStack(spacing: 40.flexible()) {
            bookCoverImage
                .frame(width: 128.flexible()*1.25, height: 169.flexible()*1.25)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
            
            if viewModel.currentState != .notStarted {
                timerStack
                    .transition(.move(edge: .trailing))
            }
        }
    }
    
    @ViewBuilder
    var bookCoverImage: some View {
        AsyncImage(url: viewModel.book.imgURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            Rectangle()
                .fill(.gray9E9E9E.opacity(0.8))
                .overlay(alignment: .center) {
                    VStack(spacing: 4.flexible()) {
                        Text(viewModel.book.title)
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                        
                        Text(viewModel.book.author)
                            .interRegular(size: 8.flexible())
                            .foregroundStyle(.text1A1A1A)
                            .multilineTextAlignment(.center)
                    }
                    .padding(4.flexible())
                }
        }
    }
    
    var progressStack: some View {
        CustomProgressView(
            currentPage: viewModel.book.progress,
            totalPages: viewModel.book.totalPages,
            progress: viewModel.book.percentProgress
        )
    }
    
    var sessionHistory: some View {
        VStack(spacing: .zero) {
            
        }
    }
}

// MARK: Timer
private extension BookTimerView {
    
    var timerStack: some View {
        VStack(spacing: 4) {
            Text(viewModel.formattedTime)
                .font(.system(size: 36.flexible(), weight: .bold, design: .rounded))
                .foregroundColor(.primary2D5F5D)
            
            Text(viewModel.statusText)
                .font(.system(size: 16.flexible(), weight: .medium))
                .foregroundColor(.gray)
        }
    }
}

// MARK: Action Buttons
private extension BookTimerView {
    
    var actionButtons: some View {
        VStack(spacing: 16) {
            switch viewModel.currentState {
            case .notStarted:
                notStartedButtons
                
            case .reading:
                readingButtons
                
            case .paused:
                pausedButtons
            }
        }
        .padding(.horizontal, 20.flexible())
        .padding(.bottom, 40.flexible())
    }
    
    private var notStartedButtons: some View {
        AppStyleButton(
            text: "Start Reading",
            image: Image(systemName: "play.fill"),
            type: .withGreenBackground
        ) {
            if viewModel.book.totalPages == 0 {
                UIApplication.shared.presentGlobalSheet(detents: [.large()]) {
                    PageSetupSheet(
                        totalPages: $viewModel.book.totalPages,
                        startPage: $viewModel.book.startPage
                    ) {
                        viewModel.addBookToFirebase()
                        viewModel.startReading()
                    }
                }
            } else {
                UIApplication.shared.presentGlobalSheet(detents: [.large()]) {
                    PageInputSheet(
                        pageCount: $viewModel.book.progress,
                        state: .startPage
                    ) {
                        viewModel.startReading()
                    }
                }
            }
        }
    }
    
    private var readingButtons: some View {
        AppStyleButton(
            text: "Pause",
            image: Image(systemName: "play.fill"),
            type: .withWhiteBackground
        ) {
            viewModel.pauseReading()
        }
    }
    
    private var pausedButtons: some View {
        VStack(spacing: 12.flexible()) {
            AppStyleButton(
                text: "Continue",
                image: Image(systemName: "play.fill"),
                type: .withGreenBackground
            ) {
                viewModel.continueReading()
            }
            
            AppStyleButton(
                text: "Finish Session",
                image: Image(systemName: "checkmark.circle.fill"),
                type: .withWhiteBackground
            ) {
                UIApplication.shared.presentGlobalSheet(detents: [.large()]) {
                    PageInputSheet(
                        pageCount: $viewModel.book.progress,
                        state: .endPage
                    ) {
                        viewModel.finishReading()
                    }
                }
            }
        }
    }
}
