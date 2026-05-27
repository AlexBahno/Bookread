//
//  StatsView.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27/05/2026.
//

import SwiftUI

struct StatsView: View {
    
    @ObservedObject var viewModel: StatsViewModel
    
    var body: some View {
        content
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.backgroundFAFAF8)
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Statistics")
            .task {
                viewModel.loadStatisticsForCurrentMonth()
            }
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
    }
    
    var content: some View {
        ScrollView {
            VStack(spacing: 16.flexible()) {
                CustomCalendar(
                    calendar: viewModel.calendar,
                    displayedMonth: $viewModel.displayedMonth,
                    selectedDate: $viewModel.selectedDate,
                    viewModel: viewModel
                )
                
                if !viewModel.getBookForTheDay().isEmpty {
                    VStack(alignment: .leading, spacing: 8.flexible()) {
                        Text("Read in that day:")
                            .interRegular(size: 26.flexible())
                            .fontWeight(.medium)
                            .foregroundStyle(.text1A1A1A)
                        ForEach(
                            Array(viewModel.getBookForTheDay().sorted { $0.value > $1.value}),
                            id: \.key
                        ) { book, duration in
                            BookStatCellView(book: book, duration: duration)
                        }
                    }
                }
            }
            .padding(.horizontal, 16.flexible())
            .padding(.bottom, 74.flexible())
        }
    }
}
