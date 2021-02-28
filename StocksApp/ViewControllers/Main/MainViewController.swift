//
//  MainViewController.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 16/02/2021.
//

import UIKit

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK:OUTLETS
    @IBOutlet weak var stockCV: UICollectionView!
    @IBOutlet weak var navBgView: UIView!
    
    //Img
    @IBOutlet weak var searchFieldBg: UIImageView!
    @IBOutlet weak var searchField: UITextField!
    
    //Buttons
    @IBOutlet weak var stocksButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var fieldButton: UIButton!
    
    //Constraints
    @IBOutlet weak var buttonsStack: UIStackView!
    @IBOutlet weak var bottomConstr: NSLayoutConstraint!
    
    var hideState = Bool()
    var visibleBottomConstraint = CGFloat()
    
    //MARK:VIEW LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSetup()
        updateData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        stockCV.reloadData()
    }
    
    func updateData() {
        getSavedFavorite()
        getStocksTrend()
        getListOfAllStocks()
    }
    
    func viewSetup() {
        hiddingKeyboardSetting()
        navBgView.makeShadowAndRadius(opacity: 0.5, radius: 8)
        visibleBottomConstraint = bottomConstr.constant
        
        stockCV.delegate = self
        stockCV.dataSource = self
        
        setTimer()
    }

    //MARK:UI
    func hideButtons(hide: Bool) {
        UIView.animate(withDuration: 0.2) {
            if hide {
                if self.hideState != true {
                    self.buttonsStack.isHidden = true
                    self.bottomConstr.constant = self.visibleBottomConstraint - self.buttonsStack.frame.height
                }
            } else {
                if self.hideState == true {
                    self.bottomConstr.constant = self.visibleBottomConstraint
                    self.buttonsStack.isHidden = false
                }
            }
            self.view.layoutIfNeeded()
        }
    }
    
    func changeStateOfView(searching: Bool) {
        if searching {
            fieldButton.setImage(UIImage(named: "cancel"), for: .normal)
            fieldButton.setBackgroundImage(nil, for: .normal)
            currentState = navigationState.searching
            hideButtons(hide: true)
            hideState = true
        } else {
            fieldButton.setImage(nil, for: .normal)
            fieldButton.setBackgroundImage(UIImage(named: "Search"), for: .normal)
            self.searchField.text = ""
            view.endEditing(true)
            
            currentState = navigationState.trends
            hideButtons(hide: false)
            hideState = false
            
            updateShowingArray()
            updateNavButtonsDesign()
            self.stockCV.reloadData()
        }
    }
    
    func updateNavButtonsDesign() {
        if currentState == navigationState.trends {
            fillNavButton(button: stocksButton, choosed: true)
            fillNavButton(button: favoriteButton, choosed: false)
        }
        else if currentState == navigationState.favorite  {
            fillNavButton(button: stocksButton, choosed: false)
            fillNavButton(button: favoriteButton, choosed: true)
        }
    }
    
    func fillNavButton(button: UIButton, choosed: Bool) {
        if choosed {
            button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 35)
            button.setTitleColor(UIColor.black, for: .normal)
        } else {
            button.titleLabel?.font = UIFont(name: "AvenirNext-Medium", size: 27)
            button.setTitleColor(UIColor.lightGray, for: .normal)
        }
    }
    
    //MARK:BUTTONS
    //Navigation buttons
    @IBAction func navButtonTapped(_ sender: UIButton) {
        if sender == favoriteButton {
            currentState = navigationState.favorite
        } else {
            currentState = navigationState.trends
        }
        
        updateShowingArray()
        updateNavButtonsDesign()
        self.stockCV.reloadData()
    }
    
    //Field button
    @IBAction func fieldButtonTapped(_ sender: UIButton) {
        changeStateOfView(searching: false)
    }
    
    //MARK:SCROLL VIEW
    var lastContentOffset: CGFloat = 0
    var lastCellIsVisible = Bool()
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 || lastCellIsVisible {
            
        } else {
            //Scrolling up
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                if currentState != navigationState.searching {
                    hideButtons(hide: false)
                    hideState = false
                }
            }
            //Scrolling down
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
                hideButtons(hide: true)
                hideState = true
            }

            self.lastContentOffset = scrollView.contentOffset.y
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        lastCellIsVisible = indexPath.row == showingStocksArray.count - 1
    }
    
    //MARK:COLLECTION VIEW
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return showingStocksArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = stockCV.dequeueReusableCell(withReuseIdentifier: "stockCell", for: indexPath) as! StockCollectionViewCell
        let stock = showingStocksArray[indexPath.row]
        
        cell.cellStock = stock
        cell.setDesign()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        reviewStock = showingStocksArray[indexPath.row]
        self.performSegue(withIdentifier: "toReview", sender: self)
    }
    
    //MARK: SEARCH FIELD
    @IBAction func fieldBegin(_ sender: UITextField) {
        changeStateOfView(searching: true)
    }
    
    @IBAction func fieldChanged(_ sender: UITextField) {
        if let textField = sender.text?.lowercased() {
            searchForStock(text: textField)
        }
    }
}
