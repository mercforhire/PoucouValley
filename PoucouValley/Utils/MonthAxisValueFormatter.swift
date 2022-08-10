//
//  MonthAxisValueFormatter.swift
//  ChartsDemo-iOS
//
//  Created by Jacob Christie on 2017-07-09.
//  Copyright © 2017 jc. All rights reserved.
//

import Foundation
import Charts

public class MonthAxisValueFormatter: NSObject, AxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        var startOfMonth = Date().startOfMonth()
        for _ in 0..<Int(value) {
            startOfMonth = startOfMonth.add(component: .month, value: -1)
        }
        if let monthInt = Calendar.current.dateComponents([.month], from: startOfMonth).month {
            return months[monthInt - 1]
        } else {
            return "\(value)"
        }
    }
}
