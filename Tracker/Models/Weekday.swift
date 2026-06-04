import UIKit

enum Weekday: Int, CaseIterable, Codable {
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
}

extension Weekday {
    init(date: Date) {
        let weekdayNumber = Calendar.current.component(.weekday, from: date)
        
        guard let weekday = Weekday(rawValue: weekdayNumber) else {
            fatalError("Invalid weekday number: \(weekdayNumber)")
        }
        
        self = weekday
    }
    
    var title: String {
        switch self {
        case .monday:
            return NSLocalizedString("weekday.monday", comment: "")
        case .tuesday:
            return NSLocalizedString("weekday.tuesday", comment: "")
        case .wednesday:
            return NSLocalizedString("weekday.wednesday", comment: "")
        case .thursday:
            return NSLocalizedString("weekday.thursday", comment: "")
        case .friday:
            return NSLocalizedString("weekday.friday", comment: "")
        case .saturday:
            return NSLocalizedString("weekday.saturday", comment: "")
        case .sunday:
            return NSLocalizedString("weekday.sunday", comment: "")
        }
    }
    
    static var orderedCases: [Weekday] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

