//
// Collection+Extension.swift
// ExpressCareCore
//
// Created by Reuben Lee on 2018-01-18.
// Copyright © 2018 DexCare. All rights reserved.
//

import Foundation

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(safe index: Index) -> Element? {
        return element(at: index)
    }

    func element(at index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
