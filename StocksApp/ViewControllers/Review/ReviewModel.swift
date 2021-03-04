//
//  ReviewModel.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 23/02/2021.
//

import Foundation
import Charts
import Alamofire

//MARK:SOURCE
var reviewStock : Stock!
var currentRequest : requestType!
var buttonChoosed = UIButton()

var dateGraphArray : [String] = []
var valueGraphArray : [Double] = []

enum requestType {
    case week
    case month
    case year
}

//X labels array
func createDescriptionGraphArray(from: [Int]) {
    dateGraphArray.removeAll()
    let df = DateFormatter()
    
    for element in from {
        let dateDay = Date(timeIntervalSince1970: TimeInterval.init(element))
        
        if currentRequest == requestType.year {
            df.dateFormat = "MMM"
            dateGraphArray.append(df.string(from: dateDay))
        }
        else if currentRequest == requestType.month {
            df.dateFormat = "dd"
            dateGraphArray.append(df.string(from: dateDay))
        }
        else if currentRequest == requestType.week {
            dateGraphArray.append(dateDay.nameOfDay())
        }
    }
}

//Value array
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

//MARK:GRAPH
extension ReviewViewController {
    //Data
    func updateGraph() {
        let dataSet = LineChartDataSet(entries: createGraphDataArray(), label: "Earning")
        graphView.xAxis.valueFormatter = IndexAxisValueFormatter(values: dateGraphArray)
        
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
    }
    
    //Design
    func setGraphDesign() {
        graphView.noDataText = "Can't find data of this time"
        graphView.rightAxis.enabled = false
        graphView.leftAxis.enabled = true
        
        graphView.legend.enabled = false
        
        graphView.xAxis.granularity = 1
        graphView.xAxis.drawGridLinesEnabled = true
        
        
        graphView.leftAxis.drawGridLinesEnabled = false
        
        graphView.xAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 13.0)!
        graphView.leftAxis.labelFont = UIFont(name: "AvenirNext-Medium", size: 13.0)!
        
        
        graphView.xAxis.avoidFirstLastClippingEnabled = true
        graphView.leftAxis.valueFormatter = YAxisValueFormatter()
        graphView.xAxis.forceLabelsEnabled = false
        graphView.fitScreen()
    }
}

class YAxisValueFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return "$" + String(format: "%.2f", value)
    }
}


