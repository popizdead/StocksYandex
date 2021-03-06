//
//  StockCollectionViewCell.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 17/02/2021.
//

import UIKit

class StockCollectionViewCell: UICollectionViewCell {
    
    var cellStock : Stock!
    
    @IBOutlet weak var tickerLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    @IBOutlet weak var difLbl: UILabel!
    
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var placeholderLbl: UILabel!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var favButton: UIButton!
    
    @IBAction func favButtonTapped(_ sender: UIButton) {
        favButtonAction(button: sender, stock: self.cellStock)
        updateShowingArray()
    }
    
    func setDesign() {
        self.makeShadowAndRadius(opacity: 0.5, radius: 8)
        self.logoImg.contentMode = UIView.ContentMode.scaleAspectFit
        self.logoImg.layer.cornerRadius = 8
        
        updateLabels()
        updateImg()
        updateButton()
    }
    
    func updateLabels() {
        nameLbl.text = cellStock.name
        tickerLbl.text = cellStock.ticker
        
        fillLabels()
        
        if cellStock.currentPrice != nil {
            loadingIndicator.animateHidding(hidding: true)
            loadingIndicator.stopAnimating()
            
            priceLbl.text = "$" + String(format: "%.2f", cellStock.currentPrice!)
            difLbl.text = cellStock.different
        } else {
            loadingIndicator.startAnimating()
            loadingIndicator.animateHidding(hidding: false)
            
            priceLbl.text = ""
            difLbl.text = ""
        }
    }
    
    
    func fillLabels() {
        if let growthCell = cellStock.isGrowth {
            if growthCell {
                difLbl.textColor = .systemGreen
            } else {
                difLbl.textColor = .red
            }
        }
    }
    
    func updateImg() {
        if let image = cashedImageDict[cellStock.ticker] {
            logoImg.image = image
            logoImg.backgroundColor = UIColor.white
            placeholderLbl.isHidden = true
        } else {
            logoImg.image = nil
            logoImg.backgroundColor = UIColor.systemGray6
            placeholderLbl.text = cellStock.ticker.prefix(2).uppercased()
            placeholderLbl.isHidden = false
        }
    }
    
    func updateButton() {
        if favoriteStocksArray.contains(where: {$0.ticker == cellStock.ticker }) {
            favButton.setImage(UIImage(named: "favButtonChoosed"), for: .normal)
        } else {
            favButton.setImage(UIImage(named: "favButton"), for: .normal)
        }
    }
    
}
