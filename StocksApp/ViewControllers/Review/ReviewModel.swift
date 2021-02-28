//
//  ReviewModel.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 23/02/2021.
//

import Foundation
import Charts
import Alamofire

//MARK:GRAPH SOURCE
var reviewStock : Stock!

var dateGraphArray : [String] = []
var valueGraphArray : [Double] = []

var currentRequest : requestType!

enum requestType {
    case week
    case month
    case year
}

//Graph source
func createDescriptionGraphArray(from: [Int]) {
    dateGraphArray.removeAll()
    for element in from {
        let df = DateFormatter()
        if currentRequest == requestType.year {
            df.dateFormat = "MMM"
        } else {
            df.dateFormat = "dd"
        }
        
        let dateDay = Date(timeIntervalSince1970: TimeInterval.init(element))
        dateGraphArray.append(df.string(from: dateDay))
    }
}

func createGraphDataArray() -> [ChartDataEntry] {
    var counter = 0
    var dataArray : [ChartDataEntry] = []
    
    for dayValue in valueGraphArray {
        let dataElement = ChartDataEntry(x: Double(counter), y: dayValue)
        dataArray.append(dataElement)
        counter += 1
    }
    
    return dataArray
}

//MARK:GRAPH DESIGN
extension ReviewViewController {
    func updateGraph() {
        let dataSet = LineChartDataSet(entries: createGraphDataArray(), label: "Earning")
        
        dataSet.colors = [UIColor.black]
        dataSet.highlightEnabled = false
        dataSet.drawCirclesEnabled = false
        dataSet.drawCircleHoleEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.circleColors = [UIColor.black]
        dataSet.lineCapType = CGLineCap.round
        dataSet.mode = .horizontalBezier
        
        let data = LineChartData(dataSet: dataSet)
        
        graphView.data = data
        
        graphView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateGraphArray)
        graphView.leftAxis.valueFormatter = YAxisValueFormatter()
        graphView.xAxis.forceLabelsEnabled = false
        graphView.fitScreen()
    }
    
    //Graph design
    func setGraphDesign() {
        graphView.noDataText = "Can't find data of this time"
        graphView.rightAxis.enabled = false
        graphView.leftAxis.enabled = true
        
        graphView.legend.enabled = false
        
        graphView.xAxis.granularity = 1
        graphView.xAxis.drawGridLinesEnabled = true
        
        
        graphView.leftAxis.drawGridLinesEnabled = false
        
        graphView.xAxis.labelFont = UIFont(name: "AvenirNext-Regular", size: 13.0)!
        graphView.leftAxis.labelFont = UIFont(name: "AvenirNext-Regular", size: 13.0)!
    }
    
    //MARK:GRAPH NETWORK
    //Preparing request
    func graphDataRequest(to: requestType) {
        self.hideGraph(hide: true)
        let today = Date()
        var res = "D"
        currentRequest = to
        
        var firstDay = TimeInterval()
        var lastDay = TimeInterval()
        
        switch to {
            case .month:
                firstDay = today.startOfMonth.timeIntervalSince1970
                lastDay = today.endOfMonth.timeIntervalSince1970
                
            case .week:
                let weekArray = today.daysOfWeek()
                
                firstDay = weekArray.first!.timeIntervalSince1970
                lastDay = weekArray.last!.timeIntervalSince1970
                
            case .year:
                let year = Calendar.current.component(.year, from: Date())
                let firstDayOfNextYear = Calendar.current.date(from: DateComponents(year: year + 1, month: 1, day: 1))!

                firstDay = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))!.timeIntervalSince1970
                lastDay = Calendar.current.date(byAdding: .day, value: -1, to: firstDayOfNextYear)!.timeIntervalSince1970
                res = "M"
        }
        
        let url = URL(string: "https://finnhub.io/api/v1/stock/candle?symbol=\(reviewStock.ticker)&resolution=\(res)&from=\(Int(firstDay))&to=\(Int(lastDay))&token=c0m006f48v6p8fvj10hg")!
        makeStatRequest(url: url)
    }
    
    //Request
    func makeStatRequest(url: URL) {
        AF.request(url).responseJSON { (response) in
            if let responseDictionary = response.value as? [String:Any] {
                if let timeArray = responseDictionary["t"] as? [Int] {
                    createDescriptionGraphArray(from: timeArray)
                }
                if let valueArray = responseDictionary["c"] as? [Double] {
                    valueGraphArray = valueArray
                }
                self.setGraphDesign()
                self.updateGraph()
                self.hideGraph(hide: false)
            }
        }
    }
}

class YAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "$" + String(format: "%.2f", value)
    }
}


