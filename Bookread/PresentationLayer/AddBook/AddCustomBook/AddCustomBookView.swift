//
//  AddCustomBookView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 06/06/2026.
//

import SwiftUI
import PhotosUI

struct AddCustomBookView: View {
    
    enum Constant {
        static let titleFieldId: String = "title"
        static let authorFieldId: String = "author"
    }
    
    @ObservedObject var viewModel: AddCustomBookViewModel
    
    @State private var showingImagePicker = false
    
    @State private var isScrollDisabled = true
    @FocusState var isTitleFocused: Bool
    @FocusState var isAuthorFocused: Bool
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Add Own Book")
            .navigationBarBackButtonHidden(viewModel.isLoading)
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $viewModel.selectedPhoto,
                matching: .images
            )
            .overlay {
                if viewModel.isLoading {
                    ZStack {
                        Color.black
                            .opacity(0.3)
                            .ignoresSafeArea()
                        
                        ProgressView()
                            .progressViewStyle(.circular)
                    }
                }
            }
            .onAppear {
                TabBarManager.shared.hide()
            }
    }
    
    var content: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24.flexible()) {
                    bookCoverImageView
                        .frame(width: 128.flexible()*1.25, height: 169.flexible()*1.25)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
                    
                    BaseTextField(
                        text: $viewModel.book.title,
                        keyboardType: .default,
                        textContextType: .name,
                        isSecureTextEntry: false,
                        placeholder: "Book`s title"
                    )
                    .focused($isTitleFocused)
                    .id(Constant.titleFieldId)
                    
                    BaseTextField(
                        text: $viewModel.book.author,
                        keyboardType: .default,
                        textContextType: .name,
                        isSecureTextEntry: false,
                        placeholder: "Author`s name"
                    )
                    .focused($isAuthorFocused)
                    .id(Constant.authorFieldId)
                    
                    AppStyleButton(
                        text: "Add Book",
                        type: .withGreenBackground,
                        isDisabled: !viewModel.isFormValid
                    ) {
                        Task {
                            await viewModel.loadBook()
                        }
                    }
                    .animation(.easeInOut, value: viewModel.isFormValid)
                }
                .padding(.horizontal, 16.flexible())
            }
            .scrollDisabled(isScrollDisabled)
            .onChange(of: isTitleFocused) {
                isScrollDisabled = !isTitleFocused
                scrollToSection(Constant.titleFieldId, isScroll: isTitleFocused, proxy)
            }
            .onChange(of: isAuthorFocused) {
                isScrollDisabled = !isAuthorFocused
                scrollToSection(Constant.authorFieldId, isScroll: isAuthorFocused, proxy)
            }
        }
    }
    
    @ViewBuilder
    var bookCoverImageView: some View {
        if let image = viewModel.bookCover {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .onTapGesture {
                    showingImagePicker = true
                }
        } else {
            Rectangle()
                .fill(.gray9E9E9E)
                .overlay {
                    Button {
                          showingImagePicker = true
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .renderingMode(.template)
                            .foregroundStyle(.text1A1A1A)
                            .scaledToFit()
                            .frame(width: 24.flexible(), height: 24.flexible())
                    }
                    .padding(12.flexible())
                    .background {
                        Circle()
                            .fill(.backgroundFAFAF8)
                    }
                }
        }
    }
}

// MARK: - Helpers
private extension AddCustomBookView {
    func scrollToSection(
        _ section: String,
        isScroll: Bool,
        _ proxy: ScrollViewProxy
    ) {
        if isScroll {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    proxy.scrollTo(section, anchor: .bottom)
                }
            }
        }
    }
}
