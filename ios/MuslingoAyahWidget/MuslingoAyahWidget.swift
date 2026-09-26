import SwiftUI
import WidgetKit

private let appGroupId = "group.com.muslingo.app"
private let openAppURL = URL(string: "muslingo:///home")

private struct WidgetCopy {
  let localeCode: String

  init(localeCode: String? = nil) {
    self.localeCode = localeCode
      ?? UserDefaults(suiteName: appGroupId)?.string(forKey: "widget_locale")
      ?? "ru"
  }

  func tr(_ ru: String, _ kk: String, _ en: String, _ ar: String) -> String {
    switch localeCode {
    case "kk": return kk
    case "en": return en
    case "ar": return ar
    default: return ru
    }
  }

  var title: String { tr("Аят дня", "Күн аяты", "Ayah of the day", "آية اليوم") }
  var preparing: String {
    tr("Аят дня готовится", "Күн аяты дайындалуда", "Your daily ayah is getting ready", "جارٍ إعداد آية اليوم")
  }
  var openApp: String {
    tr("Открой Muslingo, чтобы обновить виджет.", "Виджетті жаңарту үшін Muslingo қолданбасын аш.",
       "Open Muslingo to refresh the widget.", "افتح Muslingo لتحديث الأداة.")
  }
  var description: String {
    tr("Аят и перевод на главном экране и экране блокировки.",
       "Басты экран мен құлыптау экранындағы аят пен аударма.",
       "A daily ayah on your home screen and lock screen.",
       "آية يومية على الشاشة الرئيسية وشاشة القفل.")
  }
}

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
  let localeCode: String
  let number: Int?
  let title: String
  let arabic: String
  let translation: String
  let coachLine: String
}

private struct AyahProvider: TimelineProvider {
  private let calendar = Calendar.autoupdatingCurrent

  func placeholder(in context: Context) -> AyahEntry {
    let copy = WidgetCopy()
    return AyahEntry(
      date: Date(),
      localeCode: copy.localeCode,
      number: 1,
      title: copy.title,
      arabic: "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ",
      translation: "",
      coachLine: ""
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
    let localeCode = defaults.string(forKey: "widget_locale") ?? "ru"

    return payload.compactMap { item in
      guard let itemDate = formatter.date(from: item.date), itemDate >= today else { return nil }
      return AyahEntry(
        date: itemDate,
        localeCode: localeCode,
        number: item.number,
        title: item.title.uppercased(),
        arabic: item.arabic,
        translation: item.translation,
        coachLine: item.coachLine ?? ""
      )
    }
  }

  private func fallback() -> AyahEntry {
    let copy = WidgetCopy()
    return AyahEntry(
      date: Date(),
      localeCode: copy.localeCode,
      number: nil,
      title: "MUSLINGO",
      arabic: copy.preparing,
      translation: copy.openApp,
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
      .widgetURL(openAppURL)
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

        if !entry.translation.isEmpty {
          Text(entry.translation)
            .font(.caption2)
            .lineLimit(1)
            .minimumScaleFactor(0.78)
        }
      }
      .widgetURL(openAppURL)
      .muslingoWidgetBackground()
    } else {
      homeScreenContent
        .widgetURL(openAppURL)
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
      if !entry.translation.isEmpty {
        Text(entry.translation)
          .font(.caption)
          .foregroundColor(Color(red: 0.33, green: 0.43, blue: 0.50))
          .lineLimit(3)
      }
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
        .environment(\.locale, Locale(identifier: entry.localeCode))
        .environment(\.layoutDirection, entry.localeCode == "ar" ? .rightToLeft : .leftToRight)
    }
    .configurationDisplayName(Text(WidgetCopy().title))
    .description(Text(WidgetCopy().description))
    .supportedFamilies(supportedFamilies)
  }
}
