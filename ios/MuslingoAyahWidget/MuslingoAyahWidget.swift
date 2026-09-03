import SwiftUI
import WidgetKit

private let appGroupId = "group.com.muslingo.app"

private struct AyahPayload: Decodable {
  let date: String
  let number: Int
  let title: String
  let arabic: String
  let translation: String
}

private struct AyahEntry: TimelineEntry {
  let date: Date
  let number: Int?
  let title: String
  let arabic: String
  let translation: String
}

private struct AyahProvider: TimelineProvider {
  private let calendar = Calendar.autoupdatingCurrent

  func placeholder(in context: Context) -> AyahEntry {
    AyahEntry(
      date: Date(),
      number: 1,
      title: "АЯТ ДНЯ",
      arabic: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
      translation: "Во имя Аллаха, Милостивого, Милосердного"
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (AyahEntry) -> Void) {
    completion(entries().first ?? fallback())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<AyahEntry>) -> Void) {
    let timelineEntries = entries()
    let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))
      ?? Date().addingTimeInterval(86_400)
    completion(Timeline(
      entries: timelineEntries.isEmpty ? [fallback()] : timelineEntries,
      policy: .after(tomorrow)
    ))
  }

  private func entries() -> [AyahEntry] {
    guard
      let defaults = UserDefaults(suiteName: appGroupId),
      let raw = defaults.string(forKey: "daily_ayah_payload"),
      let data = raw.data(using: .utf8),
      let payload = try? JSONDecoder().decode([AyahPayload].self, from: data)
    else { return [] }

    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.dateFormat = "yyyy-MM-dd"
    let today = calendar.startOfDay(for: Date())

    return payload.compactMap { item in
      guard let itemDate = formatter.date(from: item.date), itemDate >= today else { return nil }
      return AyahEntry(
        date: itemDate,
        number: item.number,
        title: item.title.uppercased(),
        arabic: item.arabic,
        translation: item.translation
      )
    }
  }

  private func fallback() -> AyahEntry {
    AyahEntry(
      date: Date(),
      number: nil,
      title: "MUSLINGO",
      arabic: "Аят дня готовится",
      translation: "Открой Muslingo, чтобы обновить виджет."
    )
  }
}

private struct AyahWidgetView: View {
  let entry: AyahEntry

  var body: some View {
    VStack(alignment: .leading, spacing: 7) {
      HStack(spacing: 5) {
        Image(systemName: "sun.max.fill")
          .foregroundColor(Color(red: 0.96, green: 0.68, blue: 0.16))
        Text(entry.number.map { "\(entry.title) · №\($0)" } ?? entry.title)
          .font(.caption2.weight(.bold))
          .foregroundColor(Color(red: 0.10, green: 0.33, blue: 0.48))
      }
      Text(entry.arabic)
        .font(.system(size: 21, weight: .medium, design: .serif))
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
        .lineLimit(2)
      Text(entry.translation)
        .font(.caption)
        .foregroundColor(Color(red: 0.33, green: 0.43, blue: 0.50))
        .lineLimit(3)
    }
    .widgetURL(URL(string: "muslingo://home"))
    .muslingoWidgetBackground()
  }
}

private extension View {
  @ViewBuilder
  func muslingoWidgetBackground() -> some View {
    if #available(iOSApplicationExtension 17.0, *) {
      containerBackground(Color(red: 1.0, green: 0.99, blue: 0.97), for: .widget)
    } else {
      background(Color(red: 1.0, green: 0.99, blue: 0.97))
    }
  }
}

@main
struct MuslingoAyahWidget: Widget {
  let kind = "MuslingoAyahWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: AyahProvider()) { entry in
      AyahWidgetView(entry: entry)
    }
    .configurationDisplayName("Аят дня")
    .description("Аят и перевод, которые меняются каждый день.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
