//
//  date+extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 30/01/2021.
//

import Foundation

extension Date {
    static func isTommorow(id: Int) -> Bool {
        //var date = Date()
        return false
    }
    
    static func isDayHoliday(date: Date) -> Bool {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        
        let holidaysIn2021: [Date] = [
            formatter.date(from: "2021/04/04")!, // Wielkanoc
            formatter.date(from: "2021/04/05")!, // Wielkanoc
            formatter.date(from: "2021/05/01")!, // Święto pracy
            formatter.date(from: "2021/05/03")!, // Święto konstytucji
            formatter.date(from: "2021/05/23")!, // Zielone świątki
            formatter.date(from: "2021/06/03")!, // Boże Ciało
            formatter.date(from: "2021/08/15")!, // Święto Wojska Polskiego
            formatter.date(from: "2021/11/01")!, // Wszystkich Świętych
            formatter.date(from: "2021/11/11")!, // Święto Niepodległości
            formatter.date(from: "2021/12/25")!, // Boże Narodzenie
            formatter.date(from: "2021/12/16")!  // Boże Narodzenie
        ]
        
        for holiday in holidaysIn2021 {
            if formatter.string(from: date) == formatter.string(from: holiday) {
                return true
            }
        }
        return false
    }
    
    static func isDayWorkDay(date: Date) -> Bool {
        let weekDay = date.get(.weekday)
        
        let workingDays = [2, 3, 4, 5, 6]
        
        for number in workingDays {
            if number == weekDay {
                return true
            }
        }
        
        return false
    }
    
    static func isDaySchoolDay(date: Date, isHoliday: Bool, isWorkDay: Bool) -> Bool {
        if isHoliday || !isWorkDay {
            return false
        }
        
        if date.get(.month) == 4 && (date.get(.day) >= 1 && date.get(.day) <= 6) {
            return false // wakacje
        } else if date.get(.month) == 12 && date.get(.day) >= 23 {
            return false // Boże Narodzenie
        } else if (date.get(.month) == 6 && (date.get(.day) >= 26)) || date.get(.month) == 7 || date.get(.month) == 8 {
            return false // Wakacje
        } else if date.get(.month) == 1 && date.get(.day) <= 14  {
            return false // Przerwa świąteczna
        } else {
            return true
        }
    }
    
    static func isToday(id: Int, dateTest: Date?) -> Bool {
        var date = Date()
        let currentTime = date.get(.hour) * 60 + date.get(.minute)
        
        if currentTime < 60 && date.get(.day) != 1 {
            date.addTimeInterval(-86400)
        }
        
        if let dateTest = dateTest {
            date = dateTest
        }
        
        let isHoliday = isDayHoliday(date: date)
        let isWorkDay = isDayWorkDay(date: date)
        let isSchoolDay = isDaySchoolDay(date: date, isHoliday: isHoliday, isWorkDay: isWorkDay)
        
        switch id {
        case 1: // Dni robocze bez świąt
            if isWorkDay && !isHoliday {
                return true
            }
        case 2: // Soboty i niedziele
            if date.get(.weekday) == 7 || date.get(.weekday) == 1 {
                return true
            }
            return false
        case 3: // Dni szkolne
            return isSchoolDay
        case 4: // pon-sob bez świąt
            if (isWorkDay || date.get(.weekday) == 7) && !isHoliday {
                return true
            }
            return false
        case 5: // pon-sob ze świętami
            if isWorkDay || date.get(.weekday) == 7 {
                return true
            }
            return false
        case 6: // Niedziele i święta
            if date.get(.weekday) == 1 || isHoliday {
                return true
            }
            return false
        case 7:
            return date.get(.weekday) == 1
        case 8:
            return date.get(.weekday) == 7
        default:
            if date.get(.weekday) == 7 && !isHoliday {
                return true
            }
            return false
        }
        return false
    }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}
