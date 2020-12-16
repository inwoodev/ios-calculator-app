//
//  DoubleExtension.swift
//  Calculator
//
//  Created by Wonhee on 2020/12/15.
//

import Foundation

extension Double {
    func setPrecision() -> Double {
        let digit = 1e9
        var presisionedNumber = self * digit
        presisionedNumber.round()
        presisionedNumber /= digit
        return presisionedNumber
    }
}