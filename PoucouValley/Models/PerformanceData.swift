//
//  PerformanceData.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-04.
//

import Foundation
import RealmSwift
import Charts

class PerformanceData: BaseEmbeddedObject {
    var coins: Int = 0
    var followers: Int = 0
    var visits: Int = 0
    var visitors: List<VisitorRecord> = List()
    var visitsThisMonth: Int {
        let thisMonth = visitors.filter { record in
            return Date().startOfMonth() < record.createdDate
        }
        return thisMonth.count
    }
    
    convenience init(document: Document) {
        self.init()
        
        self.coins = document["coins"]??.asInt() ?? 0
        self.followers = document["followers"]??.asInt() ?? 0
        self.visits = document["visits"]??.asInt() ?? 0
        
        if let array = document["visitors"]??.arrayValue {
            let data: List<VisitorRecord> = List()
            for record in array {
                data.append(VisitorRecord(document: record!.documentValue!))
            }
            self.visitors = data
        }
    }
    
    func toBarChartDataEntries() -> [BarChartDataEntry] {
        // category the visitors by createdDate to most recent 12 month
        let numberOfMonth = 12
        var cutOffDate = Date().startOfMonth()
        var barChartDataEntries: [BarChartDataEntry] = []
        
        for month in 0..<numberOfMonth {
            let visitsOfTheMonth = visitors.filter { record in
                return record.createdDate > cutOffDate
            }
            let entry = BarChartDataEntry(x: Double(numberOfMonth - month), y: Double(visitsOfTheMonth.count))
            barChartDataEntries.append(entry)
            
            cutOffDate = cutOffDate.add(component: .month, value: -1)
        }
        
        return barChartDataEntries
    }
}
