import Foundation
import AppMetricaCore

final class AnalyticsService {

    static let shared = AnalyticsService()

    private init() { }

    func report(
        event: String,
        screen: String,
        item: String? = nil
    ) {

        var params: [AnyHashable: Any] = [
            "event": event,
            "screen": screen
        ]

        if let item {
            params["item"] = item
        }

        AppMetrica.reportEvent(
            name: "event",
            parameters: params
        )

        print(
            """
            Analytics:
            event = \(event)
            screen = \(screen)
            item = \(item ?? "-")
            """
        )
    }
}
