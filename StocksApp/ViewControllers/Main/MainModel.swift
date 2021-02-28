//
//  MainModel.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 17/02/2021.
//

import Foundation
import UIKit
import CoreData

//MARK: SOURCE
//State
var sourceSetted = false
var currentState = navigationState.trends

enum navigationState {
    case searching
    case favorite
    case trends
}

//Arrays
var showingStocksArray : [Stock] = []

var favoriteStocksArray : [Stock] = []
var trendsStocksArray : [Stock] = []
var searchStocksArray : [Stock] = []

var coreFavoriteStocks : [StockItem] = []
var cashedImageDict : [String:UIImage] = [:]
var descriptionStockArray : [Stock] = []

//Update source arrays
func searchForStock(text: String) {
    searchStocksArray.removeAll()
    let searchingNameArray = descriptionStockArray.filter({$0.ticker.lowercased().contains(text) || $0.name.lowercased().contains(text) })
    for index in Range(0...5) {
        if index <= searchingNameArray.count - 1 {
            let stock = searchingNameArray[index]
            stock.getData()
            searchStocksArray.append(stock)
        } else {
            continue
        }
    }
    updateShowingArray()
}

func updateShowingArray() {
    if currentState == navigationState.favorite {
        showingStocksArray = favoriteStocksArray
    } else if currentState == navigationState.trends {
        showingStocksArray = trendsStocksArray
    } else if currentState == navigationState.searching {
        showingStocksArray = searchStocksArray
    }
    sourceSetted = true
}


//MARK: CORE DATA
func deleteFavorite(stock: Stock) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let fetchRequest : NSFetchRequest<StockItem> = StockItem.fetchRequest()
    
    if let stocksArray = try? context.fetch(fetchRequest) {
        for stockElement in stocksArray {
            if stockElement.ticker == stock.ticker {
                context.delete(stockElement)
            }
        }
    }
    
    do {
        try context.save()
    } catch {
        
    }
    
}

func saveFavorite(stock: Stock) {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    guard let entity = NSEntityDescription.entity(forEntityName: "StockItem", in: context) else {
        return
    }
    
    let stockObject = StockItem(entity: entity, insertInto: context)
    
    stockObject.name = stock.name
    stockObject.ticker = stock.ticker
    
    do {
        try context.save()
    } catch {
        
    }
}

func getSavedFavorite() {
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let context = appDelegate.persistentContainer.viewContext
    
    let fetchRequest : NSFetchRequest<StockItem> = StockItem.fetchRequest()
    
    do {
        coreFavoriteStocks = try context.fetch(fetchRequest)
        convertToFavorite()
    } catch {
        
    }
}

func convertToFavorite() {
    for stockElement in coreFavoriteStocks {
        let stock = Stock(ticker: stockElement.ticker!, name: stockElement.name!)
        stock.getData()
        favoriteStocksArray.append(stock)
    }
}
