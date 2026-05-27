//
//  CustomCalendar.swift
//  Bookread
//
//  Created by Alexandr Bahno on 27/05/2026.
//

import SwiftUI

struct CustomCalendar: View {
    
    let calendar: Calendar
    @Binding var displayedMonth: Date
    @Binding var selectedDate: Date
    
    @ObservedObject var viewModel: StatsViewModel
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var weekdays: [String] {
        let symbols = calendar.shortStandaloneWeekdaySymbols
        return Array(symbols[1...6] + [symbols[0]])
    }
    
    var todayWeekdayIndex: Int {
        let originalIndex = calendar.component(.weekday, from: Date()) - 1
        return (originalIndex + 6) % 7
    }
    
    func changedMonth(by value: Int) {
//        withAnimation {
            displayedMonth = calendar.date(
                byAdding: .month,
                value: value,
                to: displayedMonth
            ) ?? displayedMonth
//        }
    }
    
    var body: some View {
        VStack(spacing: 24.flexible()) {
            monthSelection
            
            weekdaysNameView
            
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 2.flexible()), count: 7)
            ) {
                ForEach(viewModel.generateMonthGrid(), id: \.self) { date in
                    let isCurrentMonth = calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
                    let isSelected = calendar.isDate(selectedDate, inSameDayAs: date)
                    
                    VStack(spacing: 4.flexible()) {
                        bookCoverImage(date)
                            .frame(width: 128.flexible()*0.3, height: 169.flexible()*0.3)
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 4.flexible()))
                        
                        Text("\(calendar.component(.day, from: date))")
                            .font(.system(size: 15.flexible()))
//                            .frame(maxWidth: .infinity, minHeight: 45.flexible())
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(
                                isSelected ? Color.white :
                                    (isCurrentMonth ? .text1A1A1A : .gray)
                            )
                            .background(
                                isSelected ? .primary2D5F5D : .clear
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 8.flexible()))
                            .overlay {
                                RoundedRectangle(cornerRadius: 8.flexible())
                                    .stroke(lineWidth: 1.flexible())
                                    .foregroundStyle(
                                        Calendar.current.isDateInToday(date) ?
                                        Color.accentC17767 : Color.clear
                                    )
                                    .padding(1.flexible())
                            }
                    }
                    .onTapGesture {
                        if !calendar.isDate(selectedDate, inSameDayAs: date) && isCurrentMonth {
                            withAnimation {
                                selectedDate = date
                            }
                        }
                    }
                }
            }
        }
    }
    
    var monthSelection: some View {
        HStack(spacing: .zero) {
            Button {
                changedMonth(by: -1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16.flexible()))
                    .foregroundStyle(.text1A1A1A)
            }
            
            Spacer()
            Text(formatter.string(from: displayedMonth))
                .interRegular(size: 16.flexible())
            Spacer()
            
            Button {
                changedMonth(by: 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.system(size: 16.flexible()))
                    .foregroundStyle(.text1A1A1A)
            }
        }
    }
    
    var weekdaysNameView: some View {
        HStack(spacing: 2.flexible()) {
            ForEach(weekdays.indices, id: \.self) { index in
                Text(weekdays[index])
                    .interRegular(size: 14.flexible())
                    .frame(maxWidth: .infinity)
                    .foregroundStyle(.text1A1A1A)
                    .padding(.vertical, 3.flexible())
            }
        }
    }
    
    @ViewBuilder
    func bookCoverImage(_ date: Date) -> some View {
        if let url = viewModel.getTopBookImageUrl(for: date) {
            AsyncImage(url: URL(string: url)) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Rectangle()
                    .fill(.gray9E9E9E.opacity(0.8))
                    .shimmer()
            }
        } else {
            Rectangle()
                .fill(Color.backgroundFAFAF8)
        }
    }
}
