import UIKit

enum Weekday: Int, CaseIterable {
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
        self = Weekday(rawValue: weekdayNumber)!
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

