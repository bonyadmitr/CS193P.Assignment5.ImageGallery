//
//  AppDelegate.swift
//  ImageGallery
//
//  Created by Evgeniy Ziangirov on 18/07/2018.
//  Copyright © 2018 Evgeniy Ziangirov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let layuot = UICollectionViewFlowLayout()
        layuot.scrollDirection = .vertical
        layuot.finalizeAnimatedBoundsChange()
        
        //UISplitViewController()
        let splitVC = UISplitViewController()
        splitVC.delegate = self
        
        let masterNC = UINavigationController(rootViewController: TableViewController())
        let detailNC = UINavigationController(rootViewController: ImageGalleryViewController(collectionViewLayout: layuot))
        splitVC.viewControllers = [masterNC, detailNC]
        
        window?.rootViewController = splitVC
        window?.backgroundColor = .orange
        window?.makeKeyAndVisible()
        
        return true
    }
    
}

