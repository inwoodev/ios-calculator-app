//
//  BinaryCalculator.swift
//  Calculator
//
//  Created by Wonhee on 2020/12/08.
//

import Foundation

class BinaryCalculator: BinaryCalculable {
    
    static let shared: BinaryCalculator = BinaryCalculator()
    private init() {}

    private var binaryStack = Stack<BinaryData>()
    private let binaryOperator: [String] = BinaryOperatorType.allCases.map { $0.rawValue }

    func calculate(_ items: [String]) throws -> CalculatorData {
        // 후위표기식으로 바뀐 식 array
        do {
            guard binaryStack.isEmpty else {
                throw CalculatorError.calculator
            }
            let postFixFormula = try putFormula(items).map({ data -> BinaryData in
                guard let binaryData = data as? BinaryData else {
                    throw CalculatorError.unknowned
                }
                return binaryData
            })
            for formula in postFixFormula {
                // 숫자
                guard let formulaType = formula.type else {
                    binaryStack.push(formula)
                    continue
                }
                guard let secondItem = binaryStack.pop(),
                      let firstItem = binaryStack.pop() else {
                    throw CalculatorError.calculator
                }
                var resultData: CalculatorData
                switch formulaType {
                case .add:
                    resultData = try add(firstItem: firstItem, secondItem: secondItem)
                case .subtract:
                    resultData = try subtract(firstItem: firstItem, secondItem: secondItem)
                case .multiple:
                    resultData = try multiply(firstItem: firstItem, secondItem: secondItem)
                case .and:
                    resultData = try and(firstItem: firstItem, secondItem: secondItem)
                case .nand:
                    resultData = try nand(firstItem: firstItem, secondItem: secondItem)
                case .or:
                    resultData = try or(firstItem: firstItem, secondItem: secondItem)
                case .nor:
                    resultData = try nor(firstItem: firstItem, secondItem: secondItem)
                case .xor:
                    resultData = try xor(firstItem: firstItem, secondItem: secondItem)
                default:
                    throw CalculatorError.calculator
                }
                guard let result = resultData as? BinaryData else {
                    throw CalculatorError.calculator
                }
                binaryStack.push(result)
            }
            
            guard let calculatorResultData = binaryStack.pop() else {
                throw CalculatorError.calculator
            }
            return calculatorResultData
        } catch {
            throw error
        }
    }

    func putFormula(_ items: [String]) throws -> [CalculatorData] {
        var postFixFormula: [CalculatorData] = []
        for item in items {
            do {
                // 연산자일 경우
                if binaryOperator.contains(item) {
                    let operatorData = try getOperatorData(item)
                    while true {
                        // 스택이 비어 있을때
                        guard let compareOperatorData = binaryStack.peek() else {
                            binaryStack.push(operatorData)
                            break
                        }
                        guard let operatorType = operatorData.type,
                              let compareOperatorType = compareOperatorData.type,
                              operatorType.isPrecedence(compare: compareOperatorType) else {
                            binaryStack.push(operatorData)
                            break
                        }
                        postFixFormula.append(compareOperatorData)
                        binaryStack.pop()
                    }
                }
                // 숫자일 경우
                else {
                    postFixFormula.append(BinaryData(value: item, type: nil))
                }
            } catch {
                throw error
            }
        }
        while !binaryStack.isEmpty {
            guard let operatorData = binaryStack.pop() else {
                throw CalculatorError.unknowned
            }
            postFixFormula.append(operatorData)
        }
        return postFixFormula
    }

    func getOperatorData(_ item: String) throws -> BinaryData {
        guard let operatorType = BinaryOperatorType(rawValue: item) else {
            throw CalculatorError.unknowned
        }
        return BinaryData(value: item, type: operatorType)
    }

    func and(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        guard let firstValue = Int(firstItem.value, radix: 2),
              let secondValue = Int(secondItem.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = firstValue & secondValue
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func or(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        guard let firstValue = Int(firstItem.value, radix: 2),
              let secondValue = Int(secondItem.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = firstValue | secondValue
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func xor(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        guard let firstValue = Int(firstItem.value, radix: 2),
              let secondValue = Int(secondItem.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = firstValue ^ secondValue
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func nor(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        do {
            let orData = try or(firstItem: firstItem, secondItem: secondItem)
            return try not(orData)
        } catch {
            throw error
        }
    }

    func nand(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        do {
            let andData = try and(firstItem: firstItem, secondItem: secondItem)
            return try not(andData)
        } catch {
            throw error
        }
    }
    
    func add(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        guard let firstValue = Int(firstItem.value, radix: 2),
              let secondValue = Int(secondItem.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = firstValue + secondValue
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func subtract(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        guard let firstValue = Int(firstItem.value, radix: 2),
              let secondValue = Int(secondItem.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = firstValue - secondValue
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func multiply(firstItem: CalculatorData, secondItem: CalculatorData) throws -> CalculatorData {
        guard let firstValue = Int(firstItem.value, radix: 2),
              let secondValue = Int(secondItem.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = firstValue * secondValue
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }
    
    func not(_ item: CalculatorData) throws -> CalculatorData {
        guard let itemValue = Int(item.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = ~itemValue
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func leftShift(_ item: CalculatorData) throws -> CalculatorData {
        guard let itemValue = Int(item.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = itemValue << 1
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func rightShift(_ item: CalculatorData) throws -> CalculatorData {
        guard let itemValue = Int(item.value, radix: 2) else {
            throw CalculatorError.unknowned
        }
        let resultValue = itemValue >> 1
        return BinaryData(value: String(resultValue, radix: 2), type: nil)
    }

    func clear() {
        binaryStack.removeAll()
    }
}
