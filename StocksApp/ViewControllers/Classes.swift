//
//  Classes.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 17/02/2021.
//

import Foundation
import UIKit

class Stock {
    var ticker : String
    var name : String
    var logoUrl : String?
    var logoImage : UIImage?
    var isGrowth : Bool?
    var currentPrice : Double?
    var previousPrice : Double?
    var different : String?
    
    init(ticker: String, name: String) {
        self.ticker = ticker
        self.name = name
    }
    
    func getData() {
        self.getPrices()
        self.getLogo()
    }
    
    func calculatePercentage() -> String {
        let oneProc = previousPrice! / 100
        var dif = currentPrice! / oneProc
        
        if self.isGrowth! {
            dif = dif - 100
            if dif == 0 {
                return String(format: "%.2f", dif) + "%"
            } else {
                return  "+" + String(format: "%.2f", dif) + "%"
            }
        } else {
            dif = 100 - dif
            return  "-" + String(format: "%.2f", dif) + "%"
        }
    }
}

