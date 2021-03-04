//
//  NetworkModel.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 17/02/2021.
//

import Foundation
import Alamofire

let mboumKey = "GQZSmGtDxoRBkcHsi1ivfu3Q4tDD8CaY7umAovRXuHciNV1aLJ6atqbqWdot"
let finSandKey = "sandbox_c0m006f48v6p8fvj10i0"
let finKey = "c0m006f48v6p8fvj10hg"

//MARK:TRENDS
func getStocksTrend() {
    let urlString = "https://mboum.com/api/v1/co/collections/?list=most_actives&start=1&apikey=\(mboumKey)"
    AF.request(urlString).responseJSON { (response) in
        if let object = response.value as? [String:Any] {
            if let stocksArray = object["quotes"] as? [Any] {
                for stockElement in stocksArray {
                    if let stockData = stockElement as? [String:Any] {
                        if let stock = getStockFromTrendsDict(dict: stockData) {
                            trendsStocksArray.append(stock)
                        }
                    }
                }
                updateShowingArray()
            }
        }
    }
}

func getStockFromTrendsDict(dict: [String:Any]) -> Stock? {
    if let symbol = dict["symbol"] as? String {
        if let name = dict["shortName"] as? String {
            if let curPrice = dict["regularMarketPrice"] as? Double {
                if let dif = dict["regularMarketChangePercent"] as? Double {
                    var difString = String()
                    let stock = Stock(ticker: symbol, name: name)
                    
                    stock.currentPrice = curPrice
                    stock.getLogo()
                    
                    if String(dif).first == "-" {
                        stock.isGrowth = false
                        difString = String(format: "%.2f", dif) + "%"
                    } else {
                        stock.isGrowth = true
                        difString = "+" + String(format: "%.2f", dif) + "%"
                    }
                    
                    stock.different = difString
                    return stock
                }
            }
        }
    }
    return nil
}


//MARK: STOCKS
func getListOfAllStocks() {
    let urlString = "https://finnhub.io/api/v1/stock/symbol?exchange=US&token=\(finSandKey)"
    AF.request(urlString).responseJSON { (response) in
        if let objectsArray = response.value as? [Any] {
            for stockDataElement in objectsArray {
                if let stockData = stockDataElement as? [String:Any] {
                    if let stock = getStockDescriptionFromDict(dict: stockData) {
                        listStockArray.append(stock)
                    }
                }
            }
        }
    }
}


func getStockDescriptionFromDict(dict: [String:Any]) -> Stock? {
    if let name = dict["description"] as? String {
            if let ticker = dict["symbol"] as? String {
                let stock = Stock(ticker: ticker, name: name)
                return stock
            }
    }
    return nil
}


//MARK:STOCK DATA
extension Stock {
    func downloadLogo() {
        AF.request(self.logoUrl!).response { (data) in
            if let dataImg = data.data {
                let image = UIImage(data: dataImg)
                cashedImageDict[self.ticker] = image
                sourceSetted = true
            }
        }
    }
    
    func getPrices() {
        let urlString = "https://finnhub.io/api/v1/quote?symbol=\(self.ticker.uppercased())&token=\(finSandKey)"
        AF.request(urlString).responseJSON { (response) in
            if let jsonResult = response.value as? [String:Any] {
                if let curPrice = jsonResult["c"] as? Double {
                    if let prevPrice = jsonResult["pc"] as? Double {
                        if String(format: "%.2f", curPrice) == "0.00" {
                            showingStocksArray = showingStocksArray.filter({ (stock) -> Bool in
                                stock.ticker != self.ticker
                            })
                            listStockArray = listStockArray.filter({ (stock) -> Bool in
                                stock.ticker != self.ticker
                            })
                        } else {
                            self.currentPrice = curPrice
                            self.previousPrice = prevPrice
                            self.isGrowth = self.currentPrice! >= self.previousPrice!
                            self.different = self.calculatePercentage()
                        }
                        sourceSetted = true
                    }
                }
            }
        }
    }
    
    func getLogo() {
        AF.request("http://finnhub.io/api/v1/stock/profile2?symbol=\(self.ticker.uppercased())&token=\(finKey)").responseJSON { (response) in
            if let respDict = response.value as? [String:Any] {
                if let logo = respDict["logo"] as? String {
                    self.logoUrl = logo
                    self.downloadLogo()
                }
            }
        }
    }
}

//MARK:GRAPH
extension ReviewViewController {
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
                firstDay = today.startOfWeek(using: Calendar.current).timeIntervalSince1970
                lastDay = today.timeIntervalSince1970
            case .year:
                let year = Calendar.current.component(.year, from: Date())
                let firstDayOfNextYear = Calendar.current.date(from: DateComponents(year: year + 1, month: 1, day: 1))!

                firstDay = Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))!.timeIntervalSince1970
                lastDay = Calendar.current.date(byAdding: .day, value: -1, to: firstDayOfNextYear)!.timeIntervalSince1970
                res = "M"
        }
        
        let url = URL(string: "https://finnhub.io/api/v1/stock/candle?symbol=\(reviewStock.ticker)&resolution=\(res)&from=\(Int(firstDay))&to=\(Int(lastDay))&token=\(finKey)")!
        makeStatRequest(url: url)
    }
    
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


