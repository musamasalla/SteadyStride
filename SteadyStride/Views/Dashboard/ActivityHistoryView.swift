//
//  ActivityHistoryView.swift
//  SteadyStride
//
//  Created for SteadyStride - Senior Mobility Coach
//

import SwiftUI
import SwiftData

struct ActivityHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \WorkoutSession.startTime, order: .reverse) private var sessions: [WorkoutSession]
    
    var body: some View {
        List {
            if completedSessions.isEmpty {
                ContentUnavailableView(
                    "No Activity Yet",
                    systemImage: "figure.walk",
                    description: Text("Complete your first workout to see your history")
                )
            } else {
                ForEach(groupedSessions, id: \.key) { month, monthSessions in
                    Section {
                        ForEach(monthSessions) { session in
                            ActivityRow(session: session)
                        }
                    } header: {
                        Text(month)
                            .font(Typography.labelMedium)
                    }
                }
            }
        }
        .navigationTitle("Activity History")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
    
    private var completedSessions: [WorkoutSession] {
        sessions.filter { $0.status == .completed }
    }
    
    private var groupedSessions: [(key: String, value: [WorkoutSession])] {
        let grouped = Dictionary(grouping: completedSessions) { session -> String in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: session.startTime)
        }
        return grouped.sorted { $0.key > $1.key }
    }
}

struct ActivityRow: View {
    let session: WorkoutSession
    
    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color.steadyPrimary.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "figure.walk")
                    .font(.system(size: 20))
                    .foregroundColor(.steadyPrimary)
            }
            
            // Session details
            VStack(alignment: .leading, spacing: Theme.Spacing.xxs) {
                Text(session.routineName)
                    .font(Typography.labelLarge)
                    .foregroundColor(.steadyTextPrimary)
                
                Text(formattedDate)
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            }
            
            Spacer()
            
            // Duration
            VStack(alignment: .trailing, spacing: Theme.Spacing.xxs) {
                Text(formattedDuration)
                    .font(Typography.labelMedium)
                    .foregroundColor(.steadyTextPrimary)
                
                Text("\(session.completedExerciseIDs.count) exercises")
                    .font(Typography.caption)
                    .foregroundColor(.steadyTextSecondary)
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: session.startTime)
    }
    
    private var formattedDuration: String {
        let minutes = Int(session.actualDuration / 60)
        return "\(minutes) min"
    }
}

#Preview {
    NavigationStack {
        ActivityHistoryView()
    }
}
