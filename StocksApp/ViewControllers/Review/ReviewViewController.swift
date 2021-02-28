//
//  ReviewViewController.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 23/02/2021.
//

import UIKit
import Charts

class ReviewViewController: UIViewController, ChartViewDelegate {
    
    //MARK:OUTLETS
    
    //Views
    @IBOutlet weak var navigationViewBg: UIView!
    @IBOutlet weak var graphView: LineChartView!
    @IBOutlet weak var shadowGraphView: UIView!
    
    //Labels
    @IBOutlet weak var tickerLabel: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var priceLbl: UILabel!
    
    //Buttons
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var graphButtonStack: UIStackView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    //Logo
    @IBOutlet weak var logoImg: UIImageView!
    @IBOutlet weak var placeholderLogo: UILabel!
    
    @IBOutlet weak var anotherCoonstraint: NSLayoutConstraint!
    
    var buttonChoosed = UIButton()
    
    //MARK:VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        setGraphDesign()
        designSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        graphButtonTapped(monthButton)
        updateLabels()
    }
    
    //MARK:UI SETTING
    func checkForFavouriteButton() {
        if favoriteStocksArray.contains(where: { (stock) -> Bool in
            return stock.ticker == reviewStock.ticker
        }) {
            self.favButton.setImage(UIImage(named: "favButtonChoosed"), for: .normal)
        } else {
            self.favButton.setImage(UIImage(named: "favButton"), for: .normal)
        }
    }
    
    func designSetup() {
        indicator.startAnimating()
        let viewsArray = [weekButton, monthButton, yearButton, navigationViewBg, shadowGraphView]
        for viewElem in viewsArray {
            viewElem?.makeShadowAndRadius(opacity: 0.5, radius: 10)
        }
        self.logoImg.layer.cornerRadius = 10
        
        buttonChoosed = monthButton
        updateButtons()
        checkForFavouriteButton()
    }
    
    func updateLogo() {
        if cashedImageDict.keys.contains(reviewStock.ticker) {
            self.logoImg.image = cashedImageDict[reviewStock.ticker]
            logoImg.backgroundColor = .white
            placeholderLogo.text = ""
        } else {
            //Placeholder logo
            logoImg.image = nil
            logoImg.backgroundColor = UIColor.systemGray6
            placeholderLogo.text = reviewStock.ticker.prefix(2).uppercased()
            placeholderLogo.isHidden = false
        }
    }
    
    //MARK:UI UPDATE
    func updateLabels() {
        updateLogo()
        self.tickerLabel.text = reviewStock.ticker
        self.nameLbl.text = reviewStock.name
        self.priceLbl.text = "$" + String(format: "%.2f", reviewStock.currentPrice!)
    }
    
    //Buttons
    func updateButtons() {
        let buttonsArray = [weekButton, monthButton, yearButton]
        for buttonElement in buttonsArray {
            fillButton(choosed: buttonChoosed == buttonElement, button: buttonElement!)
        }
    }
    
    func fillButton(choosed: Bool, button: UIButton) {
        if choosed {
            button.backgroundColor = .black
            button.setTitleColor(.white, for: .normal)
        } else {
            button.backgroundColor = .white
            button.setTitleColor(.black, for: .normal)
        }
    }
    
    //Change view state
    func hideGraph(hide: Bool) {
        self.graphView.animateHidding(hidding: hide)
        self.priceLbl.animateHidding(hidding: hide)
        self.indicator.animateHidding(hidding: !hide)
    }
    
    func longBgView(long: Bool) {
        if long {
            self.graphButtonStack.animateHidding(hidding: true)
            UIView.animate(withDuration: 0.2) {
                self.anotherCoonstraint.constant = self.anotherCoonstraint.constant - self.graphButtonStack.frame.height
                self.view.layoutIfNeeded()
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.anotherCoonstraint.constant = self.anotherCoonstraint.constant + self.graphButtonStack.frame.height
                self.view.layoutIfNeeded()
            }
            self.graphButtonStack.animateHidding(hidding: false)
        }
    }
    
    //MARK:BUTTONS

    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //Graph buttons
    @IBAction func graphButtonTapped(_ sender: UIButton) {
        buttonChoosed = sender
        
        if sender == weekButton {
            graphDataRequest(to: .week)
        } else if sender == monthButton {
            graphDataRequest(to: .month)
        } else if sender == yearButton {
            graphDataRequest(to: .year)
        }
        
        updateButtons()
    }
    
    //Favorite button
    @IBAction func favButtonTapped(_ sender: UIButton) {
        if favoriteStocksArray.contains(where: { (stock) -> Bool in
            return stock.ticker == reviewStock.ticker
        }) {
            self.favButton.setImage(UIImage(named: "favButton"), for: .normal)
            favoriteStocksArray = favoriteStocksArray.filter { $0.ticker != reviewStock.ticker }
            deleteFavorite(stock: reviewStock)
        } else {
            self.favButton.setImage(UIImage(named: "favButtonChoosed"), for: .normal)
            favoriteStocksArray.append(reviewStock)
            saveFavorite(stock: reviewStock)
        }
    }
    
}

