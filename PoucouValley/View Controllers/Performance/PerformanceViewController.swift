//
//  PerformanceViewController.swift
//  PoucouValley
//
//  Created by Leon Chen on 2022-08-04.
//

import UIKit
import Charts

class PerformanceViewController: BaseViewController {

    @IBOutlet weak var greenView: UIView!
    @IBOutlet weak var coinsLabel: ThemeWhiteTextLabel!
    @IBOutlet weak var rankingLabel: ThemeWhiteTextLabel!
    @IBOutlet weak var favoritesLabel: ThemeBlackTextLabel!
    @IBOutlet weak var visitsLabel: ThemeBlackTextLabel!
    @IBOutlet weak var visitsThisMonth: ThemeGreenTextLabel!
    @IBOutlet weak var monthlyChart: BarChartView!
    
    private var performanceData: PerformanceData? {
        didSet {
            guard let performanceData = performanceData else { return }
            
            coinsLabel.text = "\(performanceData.coins)"
            favoritesLabel.text = "\(performanceData.followers)"
            visitsLabel.text = "\(performanceData.visits)"
            visitsThisMonth.text = "\(performanceData.visitsThisMonth)"
            
            generateDataSet()
        }
    }
    
    override func setup() {
        super.setup()
        
        greenView.backgroundColor = themeManager.themeData?.lighterGreen.hexColor
        greenView.roundSelectedCorners(corners: [.bottomLeft], radius: 20)
        coinsLabel.text = "--"
        rankingLabel.text = "--"
        favoritesLabel.text = "--"
        visitsLabel.text = "--"
        visitsThisMonth.text = "--"
        
        let xAxis = monthlyChart.xAxis
        xAxis.labelPosition = .bottom
        xAxis.labelFont = .systemFont(ofSize: 10)
        xAxis.valueFormatter = MonthAxisValueFormatter(chart: monthlyChart)
        xAxis.drawAxisLineEnabled = false
        xAxis.drawGridLinesEnabled = false
        xAxis.labelCount = 12
        
        let leftAxisFormatter = NumberFormatter()
        leftAxisFormatter.minimumFractionDigits = 0
        leftAxisFormatter.maximumFractionDigits = 1
        let defaultAxisValueFormatter = DefaultAxisValueFormatter(formatter: leftAxisFormatter)
        defaultAxisValueFormatter.decimals = 0
        
        let leftAxis = monthlyChart.leftAxis
        leftAxis.labelFont = .systemFont(ofSize: 10)
        leftAxis.labelCount = 4
        leftAxis.valueFormatter = defaultAxisValueFormatter
        leftAxis.labelPosition = .outsideChart
        leftAxis.spaceTop = 0.15
        leftAxis.axisMinimum = 0
        leftAxis.drawAxisLineEnabled = false
        leftAxis.drawGridLinesEnabled = false
        
        let rightAxis = monthlyChart.rightAxis
        rightAxis.enabled = false
        
        monthlyChart.scaleXEnabled = false
        monthlyChart.scaleYEnabled = false
    }
    
    override func setupTheme() {
        super.setupTheme()
        
        view.backgroundColor = themeManager.themeData?.whiteBackground.hexColor
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
        fetchContents()
    }
    
    private func fetchContents(complete: ((Bool) -> Void)? = nil) {
        performanceData == nil ? FullScreenSpinner().show() : nil
        
        api.fetchPerformanceData { [weak self] result in
            guard let self = self else { return }
            
            FullScreenSpinner().hide()
            
            switch result {
            case .success(let response):
                if response.success, let data = response.data {
                    self.performanceData = data
                    complete?(true)
                } else {
                    showErrorDialog(error: response.message)
                    complete?(false)
                }
                complete?(true)
            case .failure:
                showNetworkErrorDialog()
                complete?(false)
            }
        }
    }
    
    private func generateDataSet() {
        guard let performanceData = performanceData else { return }
        
        let dateSet = BarChartDataSet(entries: performanceData.toBarChartDataEntries(), label: "Visits")
        dateSet.colors = [themeManager.themeData!.lighterGreen.hexColor]
        dateSet.drawValuesEnabled = false
        dateSet.barBorderColor = themeManager.themeData!.lighterGreen.hexColor
        dateSet.barBorderWidth = 1
        
        let data = BarChartData(dataSet: dateSet)
        data.setDrawValues(false)
        data.setValueTextColor(themeManager.themeData!.steel.hexColor)
        data.barWidth = 0.5
        monthlyChart.data = data
    }
}
