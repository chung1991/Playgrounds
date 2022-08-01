import UIKit
import Foundation

var greeting = "Hello, playground"

class CalendarUtils {
    let calendar: Calendar = Calendar.current
    let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        return dateFormatter
    }()
    
    func getFirstDayInMonth(_ date: Date) -> Date {
        let comps = calendar.dateComponents([.month, .year], from: date)

        guard let month = comps.month,
              let year = comps.year,
              let ans = dateFormatter.date(from: "01-\(month)-\(year)") else {
            return Date()
        }
        return ans
    }
    
    func nextMonth(_ date: Date) -> Date {
        guard let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: date) else {
            return Date()
        }
        return getFirstDayInMonth(nextMonthDate)
    }
    
    func prevMonth(_ date: Date) -> Date {
        guard let prevMonthDate = calendar.date(byAdding: .month, value: -1, to: date) else {
            return Date()
        }
        return getFirstDayInMonth(prevMonthDate)
    }
    
    func getWeekDayOffset(_ date: Date) -> Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday - 1
    }
    
    func getMaxDay(_ date: Date) -> Int {
        let firstDayInCurrentMonth = getFirstDayInMonth(date)
        let fistDayInNextMonth = nextMonth(firstDayInCurrentMonth)
        let diff = calendar.dateComponents([.day],
                                           from: firstDayInCurrentMonth,
                                           to: fistDayInNextMonth)
        return diff.day!
    }
}

let util = CalendarUtils()
print (util.getFirstDayInMonth(Date()))
print (util.nextMonth(Date()))
print (util.prevMonth(Date()))


let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "dd-MM-yyyy"
print (util.getMaxDay(dateFormatter.date(from: "05/02/2022")!))
print (util.getMaxDay(dateFormatter.date(from: "05/03/2022")!))
print (util.getMaxDay(dateFormatter.date(from: "05/04/2022")!))
print (util.getMaxDay(dateFormatter.date(from: "05/05/2022")!))
print (util.getMaxDay(dateFormatter.date(from: "05/06/2022")!))
