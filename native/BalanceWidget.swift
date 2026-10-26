import WidgetKit
import SwiftUI

private let appGroup = "group.com.example.finance"
private let green = Color(red: 0.086, green: 0.639, blue: 0.290)

struct BalanceEntry: TimelineEntry {
    let date: Date
    let balance: Double
}

struct BalanceProvider: TimelineProvider {
    func placeholder(in context: Context) -> BalanceEntry { BalanceEntry(date: Date(), balance: 0) }
    func getSnapshot(in context: Context, completion: @escaping (BalanceEntry) -> Void) { completion(load()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<BalanceEntry>) -> Void) {
        completion(Timeline(entries: [load()], policy: .never))
    }
    private func load() -> BalanceEntry {
        let v = UserDefaults(suiteName: appGroup)?.double(forKey: "balance") ?? 0
        return BalanceEntry(date: Date(), balance: v)
    }
}

struct BalanceWidgetView: View {
    let entry: BalanceEntry

    private var formatted: String {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "RUB"
        f.locale = Locale(identifier: "ru_RU")
        f.maximumFractionDigits = 0
        return f.string(from: NSNumber(value: entry.balance)) ?? "\(entry.balance)"
    }

    private func button(_ symbol: String, _ bg: Color) -> some View {
        Text(symbol)
            .font(.system(size: 26, weight: .bold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 38)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Баланс").font(.footnote).foregroundColor(.gray)
            Text(formatted)
                .font(.system(size: 30, weight: .bold))
                .foregroundColor(.black)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Spacer(minLength: 0)
            HStack(spacing: 10) {
                // слева: расход
                Link(destination: URL(string: "finance://add?type=exp")!) { button("−", .black) }
                // справа: доход
                Link(destination: URL(string: "finance://add?type=inc")!) { button("+", green) }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .containerBackground(Color.white, for: .widget)
    }
}

@main
struct BalanceWidget: Widget {
    let kind = "BalanceWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: BalanceProvider()) { entry in
            BalanceWidgetView(entry: entry)
        }
        .configurationDisplayName("Баланс")
        .description("Текущий баланс и быстрые кнопки дохода и расхода")
        .supportedFamilies([.systemMedium])
    }
}
