//
//  AppDelegate.swift
//  FetchDocument
//
//  Created by Nirzar Gandhi on 05/03/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // MARK: - Properties
    internal var window: UIWindow?
    var navController : UINavigationController?
    
    
    // MARK: - RootView Setup
    func setRootViewController(rootVC: UIViewController) {
        
        self.navController = UINavigationController(rootViewController: rootVC)
        self.window?.rootViewController = self.navController
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Set Root Controller
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = .white
        let fetchDocumentVC = GetStoryBoard(identifier: "FetchDocumentVC", storyBoardName: Constants.Storyboard.Main) as! FetchDocumentVC
        self.setRootViewController(rootVC: fetchDocumentVC)
        
        self.window?.makeKeyAndVisible()
        
        return true
    }
}

