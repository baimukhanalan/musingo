import SwiftUI
import WidgetKit

private let appGroupId = "group.com.muslingo.app"

private struct AyahPayload: Decodable {
  let date: String
  let number: Int
  let title: String
  let arabic: String
  let translation: String
  let coachLine: String?
}

private struct AyahEntry: TimelineEntry {
  let date: Date
  let number: Int?
  let title: String
  let arabic: String
  let translation: String
  let coachLine: String
}

private struct AyahProvider: TimelineProvider {
  private let calendar = Calendar.autoupdatingCurrent

  func placeholder(in context: Context) -> AyahEntry {
    AyahEntry(
      date: Date(),
      number: 1,
      title: "АЯТ ДНЯ",
      arabic: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
      translation: "Во имя Аллаха, Милостивого, Милосердного",
      coachLine: "Айн: короткий шаг на сегодня"
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
        translation: item.translation,
        coachLine: item.coachLine ?? ""
      )
    }
  }

  private func fallback() -> AyahEntry {
    AyahEntry(
      date: Date(),
      number: nil,
      title: "MUSLINGO",
      arabic: "Аят дня готовится",
      translation: "Открой Muslingo, чтобы обновить виджет.",
      coachLine: ""
    )
  }
}

private struct AyahWidgetView: View {
  let entry: AyahEntry
  @Environment(\.widgetFamily) private var family

  @ViewBuilder
  var body: some View {
    if #available(iOSApplicationExtension 16.0, *), family == .accessoryInline {
      Label {
        Text("\(entry.title): \(entry.arabic)")
      } icon: {
        Image(systemName: "book.closed.fill")
      }
      .widgetAccentable()
      .widgetURL(URL(string: "https://muslingo-mobile.vercel.app/#/home"))
    } else if #available(iOSApplicationExtension 16.0, *), family == .accessoryRectangular {
      VStack(alignment: .leading, spacing: 2) {
        HStack(spacing: 4) {
          Image(systemName: "book.closed.fill")
          Text(entry.number.map { "\(entry.title) · №\($0)" } ?? entry.title)
            .lineLimit(1)
        }
        .font(.caption2.weight(.bold))
        .widgetAccentable()

        Text(entry.arabic)
          .font(.system(size: 16, weight: .semibold, design: .serif))
          .lineLimit(1)
          .minimumScaleFactor(0.72)
          .frame(maxWidth: .infinity, alignment: .leading)

        Text(entry.translation)
          .font(.caption2)
          .lineLimit(1)
          .minimumScaleFactor(0.78)
      }
      .widgetURL(URL(string: "https://muslingo-mobile.vercel.app/#/home"))
      .muslingoWidgetBackground()
    } else {
      homeScreenContent
        .widgetURL(URL(string: "https://muslingo-mobile.vercel.app/#/home"))
        .muslingoWidgetBackground()
    }
  }

  private var homeScreenContent: some View {
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
      if !entry.coachLine.isEmpty && family == .systemMedium {
        Divider().opacity(0.35)
        Text(entry.coachLine)
          .font(.caption2.weight(.semibold))
          .foregroundColor(Color(red: 0.10, green: 0.33, blue: 0.48))
          .lineLimit(1)
      }
    }
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

  private var supportedFamilies: [WidgetFamily] {
    if #available(iOSApplicationExtension 16.0, *) {
      return [
        .systemSmall,
        .systemMedium,
        .accessoryInline,
        .accessoryRectangular,
      ]
    }
    return [.systemSmall, .systemMedium]
  }

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: AyahProvider()) { entry in
      AyahWidgetView(entry: entry)
    }
    .configurationDisplayName("Аят дня")
    .description("Аят и перевод на главном экране и экране блокировки.")
    .supportedFamilies(supportedFamilies)
  }
}
