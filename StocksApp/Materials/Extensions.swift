//
//  Extensions.swift
//  StocksApp
//
//  Created by Даниил Дорожкин on 17/02/2021.
//

import Foundation
import UIKit

extension UIView {
    func makeShadowAndRadius(opacity: Float, radius: Float) {
        self.layer.cornerRadius = CGFloat(radius)
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = .zero
        self.layer.shadowRadius = CGFloat(radius)
        self.layer.masksToBounds = false
    }
    
    func animateHidding(hidding: Bool) {
        UIView.animate(withDuration: 0.1, delay: 0, options: [], animations: {
            if hidding {
                self.alpha = 0
            } else {
                self.alpha = 1
            }
        }, completion: { _ in
            self.isHidden = hidding
        })
    }
}

extension MainViewController {
    func hiddingKeyboardSetting() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
    func setTimer() {
        let _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(reloadCollectionView), userInfo: nil, repeats: true)
    }
    
    @objc func reloadCollectionView() {
        if sourceSetted {
            stockCV.reloadData()
            sourceSetted = false
        }
    }
}

extension Date {
    func dateComponents(_ components: Set<Calendar.Component>, using calendar: Calendar = .current) -> DateComponents {
        calendar.dateComponents(components, from: self)
    }
    
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.date(from: dateComponents([.yearForWeekOfYear, .weekOfYear], using: calendar))!
    }
    
    var startOfMonth: Date {
            let calendar = Calendar(identifier: .gregorian)
            let components = calendar.dateComponents([.year, .month], from: self)

            return  calendar.date(from: components)!
    }
    
    var endOfMonth: Date {
            var components = DateComponents()
            components.month = 1
            components.second = -1
            return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    func nameOfDay() -> String {
        let weekdays = [
            "SUN",
            "MON",
            "TUE",
            "WED",
            "THU",
            "FRI",
            "SAT"
        ]

        let calendar: Calendar = Calendar.current
        let components = calendar.component(.weekday, from: self)
        return weekdays[components - 1]
    }
}
