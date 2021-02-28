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

//MARK:STOCKS TRENDS
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


//MARK: STOCKS SOURCE
func getListOfAllStocks() {
    let urlString = "https://finnhub.io/api/v1/stock/symbol?exchange=US&token=\(finSandKey)"
    AF.request(urlString).responseJSON { (response) in
        if let objectsArray = response.value as? [Any] {
            for stockDataElement in objectsArray {
                if let stockData = stockDataElement as? [String:Any] {
                    if let stock = getStockDescriptionFromDict(dict: stockData) {
                        descriptionStockArray.append(stock)
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


//MARK:STOCK NETWORK
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




