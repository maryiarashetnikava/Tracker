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
        case .monday: return "Понедельник"
        case .tuesday: return "Вторник"
        case .wednesday: return "Среда"
        case .thursday: return "Четверг"
        case .friday: return "Пятница"
        case .saturday: return "Суббота"
        case .sunday: return "Воскресенье"
        }
    }
    
    static var orderedCases: [Weekday] {
        [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    }
}

