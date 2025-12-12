//
//  MainTabView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(AppTab.home.rawValue, systemImage: AppTab.home.icon)
                }
                .tag(AppTab.home)
            
            ExerciseLibraryView()
                .tabItem {
                    Label(AppTab.exercises.rawValue, systemImage: AppTab.exercises.icon)
                }
                .tag(AppTab.exercises)
            
            ProgressDashboardView()
                .tabItem {
                    Label(AppTab.progress.rawValue, systemImage: AppTab.progress.icon)
                }
                .tag(AppTab.progress)
            
            FamilyHubView()
                .tabItem {
                    Label(AppTab.family.rawValue, systemImage: AppTab.family.icon)
                }
                .tag(AppTab.family)
            
            ProfileView()
                .tabItem {
                    Label(AppTab.profile.rawValue, systemImage: AppTab.profile.icon)
                }
                .tag(AppTab.profile)
        }
        .tint(.steadyPrimary)
    }
}

#Preview {
    MainTabView()
}
