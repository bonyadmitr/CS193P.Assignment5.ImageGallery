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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let layuot = UICollectionViewFlowLayout()
        layuot.scrollDirection = .vertical
        layuot.finalizeAnimatedBoundsChange()
        
        let splitVC = UISplitViewController(nibName: nil, bundle: nil)
        splitVC.delegate = self
        
        let masterNC = UINavigationController(rootViewController: TableViewController(nibName: nil, bundle: nil))
        let detailNC = UINavigationController(rootViewController: ImageGalleryViewController(collectionViewLayout: layuot))
        splitVC.viewControllers = [masterNC, detailNC]
        
        window?.rootViewController = splitVC
        window?.backgroundColor = .orange
        window?.makeKeyAndVisible()
        
        return true
    }
    
}

