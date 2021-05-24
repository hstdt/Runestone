//
//  TreeSitterPredicatesValidator.swift
//  
//
//  Created by Simon Støvring on 23/02/2021.
//

import Foundation

final class TreeSitterTextPredicatesEvaluator {
    private let match: TreeSitterQueryMatch
    private let stringView: StringView

    init(match: TreeSitterQueryMatch, stringView: StringView) {
        self.match = match
        self.stringView = stringView
    }

    func evaluatePredicates(in capture: TreeSitterCapture) -> Bool {
        guard !capture.textPredicates.isEmpty else {
            return true
        }
        for textPredicate in capture.textPredicates {
            switch textPredicate {
            case .captureEqualsString(let parameters):
                if !evaluate(using: parameters) {
                    return false
                }
            case .captureEqualsCapture(let parameters):
                if !evaluate(using: parameters) {
                    return false
                }
            case .captureMatchesPattern(let parameters):
                if !evaluate(using: parameters) {
                    return false
                }
            }
        }
        return true
    }
}

private extension TreeSitterTextPredicatesEvaluator {
    func evaluate(using parameters: TreeSitterTextPredicate.CaptureEqualsStringParameters) -> Bool {
        guard let capture = match.capture(forIndex: parameters.captureIndex) else {
            return false
        }
        let byteRange = capture.byteRange
        let range = NSRange(location: byteRange.location.value / 2, length: byteRange.length.value / 2)
        let contentText = stringView.substring(in: range)
        let comparisonResult = contentText == parameters.string
        return comparisonResult == parameters.isPositive
    }

    func evaluate(using parameters: TreeSitterTextPredicate.CaptureEqualsCaptureParameters) -> Bool {
        guard let lhsCapture = match.capture(forIndex: parameters.lhsCaptureIndex) else {
            return false
        }
        guard let rhsCapture = match.capture(forIndex: parameters.lhsCaptureIndex) else {
            return false
        }
        let lhsByteRange = lhsCapture.byteRange
        let rhsByteRange = rhsCapture.byteRange
        let lhsRange = NSRange(location: lhsByteRange.location.value / 2, length: rhsByteRange.length.value / 2)
        let rhsRange = NSRange(location: lhsByteRange.location.value / 2, length: rhsByteRange.length.value / 2)
        let lhsContentText = stringView.substring(in: lhsRange)
        let rhsContentText = stringView.substring(in: rhsRange)
        let comparisonResult = lhsContentText == rhsContentText
        return comparisonResult == parameters.isPositive
    }

    func evaluate(using parameters: TreeSitterTextPredicate.CaptureMatchesPatternParameters) -> Bool {
        guard let capture = match.capture(forIndex: parameters.captureIndex) else {
            return false
        }
        let byteRange = capture.byteRange
        let range = NSRange(location: byteRange.location.value / 2, length: byteRange.length.value / 2)
        let contentText = stringView.substring(in: range)
        let matchingRange = contentText.range(of: parameters.pattern, options: .regularExpression)
        let isMatch = matchingRange != nil
        return isMatch == parameters.isPositive
    }
}
