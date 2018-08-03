//
//  Extensions.swift
//  ImageGallery
//
//  Created by Evgeniy Ziangirov on 18/07/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

extension UIView {
    func activateConstraints(withVisualFormat: String, for views: UIView...) {
        var viewsDictionary = [String: UIView]()
        views.indices.forEach {
            let key = "v\($0)"
            views[$0].translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = views[$0]
        }
        NSLayoutConstraint
            .activate(
                NSLayoutConstraint
                    .constraints(
                        withVisualFormat: withVisualFormat,
                        metrics: nil,
                        views: viewsDictionary))
    }
}

extension URL {
    var embeddedImageURL: URL {
        // check to see if there is an embedded imgurl reference
        for query in query?.components(separatedBy: "&") ?? [] {
            let queryComponents = query.components(separatedBy: "=")
            if queryComponents.count == 2 {
                if queryComponents[0] == "imgurl", let url = URL(string: queryComponents[1].removingPercentEncoding ?? "") {
                    return url
                }
            }
        }
        return self.baseURL ?? self
    }
}

extension CGSize {
    var aspectRatio: CGFloat {
        return self.width / self.height
    }
}

extension UIViewController {
    var contents: UIViewController {
        if let navcon = self as? UINavigationController {
            return navcon.visibleViewController ?? navcon
        } else {
            return self
        }
    }
}

extension UIColor {
    static let lead = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
    static let clover = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
}

/// не советую создавать такие extensions
/// сам так раньше делал, ухожу от этого
/// функция достаточно узкая по предназначению
/// я бы сделал класс и фукнцию куда передавал бы строку
extension String {
    func madeUnique(withRespectTo otherStrings: [String]) -> String {
        var possiblyUnique = self
        var uniqueNumber = 1
        while otherStrings.contains(possiblyUnique) {
            possiblyUnique = self + " \(uniqueNumber)"
            uniqueNumber += 1
        }
        return possiblyUnique
    }
}
