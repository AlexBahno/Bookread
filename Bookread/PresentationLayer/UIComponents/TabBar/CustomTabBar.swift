//
//  CustomTabBar.swift
//  Bookread
//
//  Created by Alexandr Bahno on 06.01.2026.
//

import Combine
import SwiftUI

final class TabBarState: ObservableObject {
    
    @Published var selectedTab: Tab = .home
}

struct CustomTabBar: View {
    
    @ObservedObject var tabState: TabBarState
    @Namespace var namespace
    
    func isActive(tab: Tab) -> Bool {
        tab == tabState.selectedTab
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: .zero) {
            ForEach(Tab.allCases) { item in
                Button {
                    tabState.selectedTab = item
                } label: {
                    if isActive(tab: item) {
                        VStack(spacing: .zero) {
                            VStack(spacing: 4.flexible()) {
                                Image(systemName: item.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.primary2D5F5D)
                                    .fontWeight(.medium)
                                    .frame(width: 24.flexible(), height: 24.flexible())
                                
                                Text(item.title)
                                    .interRegular(size: 12.flexible())
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary2D5F5D)
                            }
                            .padding(8.flexible())
                            .background {
                                RoundedRectangle(cornerRadius: 12.flexible())
                                    .fill(Color.primary2D5F5D.opacity(0.15))
                                    .matchedGeometryEffect(id: "box", in: namespace)
                            }
                            Spacer()
                        }
                        .padding(.top, 8.flexible())
                        .frame(maxWidth: .infinity, alignment: .center)
                    } else {
                        VStack(spacing: .zero) {
                            VStack(spacing: 4.flexible()) {
                                Image(systemName: item.icon)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(.gray666666)
                                    .fontWeight(.medium)
                                    .frame(width: 24.flexible(), height: 24.flexible())
                                
                                Text(item.title)
                                    .interRegular(size: 12.flexible())
                                    .fontWeight(.medium)
                                    .foregroundStyle(.gray666666)
                            }
                            .padding(8.flexible())
                            .frame(minWidth: 50.flexible())
                            Spacer()
                        }
                        .padding(.top, 8.flexible())
                        .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
        }
        .background {
            Rectangle()
                .fill(Color.white)
                .cornerRadius(32.flexible(), corners: .allCorners)
                .shadow(color: .black.opacity(0.1), radius: 2.flexible())
        }
        .animation(.spring, value: tabState.selectedTab)
    }
}
