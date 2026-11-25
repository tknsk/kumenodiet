import WidgetKit
import SwiftUI

struct DietAppEntry: TimelineEntry {
    let date: Date
    let caloriesConsumed: Int
    let caloriesRemaining: Int
}

struct DietAppWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DietAppEntry {
        DietAppEntry(date: .now, caloriesConsumed: 0, caloriesRemaining: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (DietAppEntry) -> Void) {
        let snapshot = WidgetSnapshotStore.load()
        completion(DietAppEntry(date: .now, caloriesConsumed: snapshot.caloriesConsumed, caloriesRemaining: snapshot.caloriesRemaining))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DietAppEntry>) -> Void) {
        let snapshot = WidgetSnapshotStore.load()
        let entry = DietAppEntry(
            date: .now,
            caloriesConsumed: snapshot.caloriesConsumed,
            caloriesRemaining: snapshot.caloriesRemaining
        )
        completion(Timeline(entries: [entry], policy: .after(.now.addingTimeInterval(60 * 30))))
    }
}

struct DietAppWidgetEntryView: View {
    var entry: DietAppWidgetProvider.Entry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("残りカロリー")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(entry.caloriesRemaining) kcal")
                .font(.title2.bold())
            Text("摂取 \(entry.caloriesConsumed) kcal")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.orange.gradient, for: .widget)
    }
}

struct DietAppWidget: Widget {
    let kind: String = "DietAppWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DietAppWidgetProvider()) { entry in
            DietAppWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("今日の残りカロリー")
        .description("摂取・消費カロリーから今日の残りカロリーを表示します。")
        .supportedFamilies([.systemSmall])
    }
}
