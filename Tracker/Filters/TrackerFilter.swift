import Foundation

enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case uncompleted

    var title: String {
        switch self {
        case .all:
            return NSLocalizedString("filters.all", comment: "")
        case .today:
            return NSLocalizedString("filters.today", comment: "")
        case .completed:
            return NSLocalizedString("filters.completed", comment: "")
        case .uncompleted:
            return NSLocalizedString("filters.uncompleted", comment: "")
        }
    }
}
