//
//  SteadyStrideWidget.swift
//  SteadyStrideWidget
//
//  Created for SteadyStride - Senior Mobility Coach
//

import WidgetKit
import SwiftUI

// MARK: - Widget Timeline Entry
struct SteadyStrideEntry: TimelineEntry {
    let date: Date
    let streak: Int
    let todayComplete: Bool
    let nextWorkoutName: String
    let minutesToday: Int
}

// MARK: - Timeline Provider
struct SteadyStrideProvider: TimelineProvider {
    func placeholder(in context: Context) -> SteadyStrideEntry {
        SteadyStrideEntry(
            date: Date(),
            streak: 7,
            todayComplete: false,
            nextWorkoutName: "Morning Balance",
            minutesToday: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SteadyStrideEntry) -> Void) {
        let entry = SteadyStrideEntry(
            date: Date(),
            streak: UserDefaults(suiteName: "group.com.steadystride.app")?.integer(forKey: "currentStreak") ?? 7,
            todayComplete: UserDefaults(suiteName: "group.com.steadystride.app")?.bool(forKey: "todayComplete") ?? false,
            nextWorkoutName: "Morning Balance",
            minutesToday: UserDefaults(suiteName: "group.com.steadystride.app")?.integer(forKey: "minutesToday") ?? 0
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SteadyStrideEntry>) -> Void) {
        let defaults = UserDefaults(suiteName: "group.com.steadystride.app")
        
        let entry = SteadyStrideEntry(
            date: Date(),
            streak: defaults?.integer(forKey: "currentStreak") ?? 0,
            todayComplete: defaults?.bool(forKey: "todayComplete") ?? false,
            nextWorkoutName: defaults?.string(forKey: "nextWorkoutName") ?? "Morning Balance",
            minutesToday: defaults?.integer(forKey: "minutesToday") ?? 0
        )
        
        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Views
struct SteadyStrideWidgetEntryView: View {
    var entry: SteadyStrideProvider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .accessoryCircular:
            CircularWidgetView(entry: entry)
        case .accessoryRectangular:
            RectangularWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let entry: SteadyStrideEntry
    
    var body: some View {
        VStack(spacing: 8) {
            // Streak
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(entry.streak)")
                    .font(.title2.bold())
            }
            
            // Status
            if entry.todayComplete {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.green)
                Text("Done!")
                    .font(.caption)
            } else {
                Image(systemName: "figure.walk")
                    .font(.system(size: 32))
                    .foregroundColor(.teal)
                Text("Start")
                    .font(.caption)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let entry: SteadyStrideEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Left side - Status
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .foregroundColor(.orange)
                    Text("\(entry.streak) day streak")
                        .font(.subheadline.bold())
                }
                
                Text(entry.todayComplete ? "Workout Complete! 🎉" : entry.nextWorkoutName)
                    .font(.headline)
                    .foregroundColor(entry.todayComplete ? .green : .primary)
                
                if entry.minutesToday > 0 {
                    Text("\(entry.minutesToday) min today")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Right side - Action button
            if !entry.todayComplete {
                if let url = URL(string: "steadystride://startworkout") {
                    Link(destination: url) {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.teal)
                    }
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.green)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Lock Screen Circular Widget
struct CircularWidgetView: View {
    let entry: SteadyStrideEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Image(systemName: entry.todayComplete ? "checkmark" : "figure.walk")
                    .font(.title3)
                Text("\(entry.streak)")
                    .font(.caption2.bold())
            }
        }
    }
}

// MARK: - Lock Screen Rectangular Widget
struct RectangularWidgetView: View {
    let entry: SteadyStrideEntry
    
    var body: some View {
        HStack {
            Image(systemName: "flame.fill")
                .foregroundColor(.orange)
            VStack(alignment: .leading) {
                Text("SteadyStride")
                    .font(.caption.bold())
                Text(entry.todayComplete ? "✓ Complete" : "\(entry.streak) day streak")
                    .font(.caption2)
            }
        }
    }
}

// MARK: - Main Widget
struct SteadyStrideWidget: Widget {
    let kind: String = "SteadyStrideWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: SteadyStrideProvider()) { entry in
            SteadyStrideWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SteadyStride")
        .description("Track your workout streak and today's progress.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryCircular,
            .accessoryRectangular
        ])
    }
}

// MARK: - Preview
#Preview(as: .systemSmall) {
    SteadyStrideWidget()
} timeline: {
    SteadyStrideEntry(date: .now, streak: 7, todayComplete: false, nextWorkoutName: "Morning Balance", minutesToday: 0)
    SteadyStrideEntry(date: .now, streak: 8, todayComplete: true, nextWorkoutName: "Morning Balance", minutesToday: 15)
}
