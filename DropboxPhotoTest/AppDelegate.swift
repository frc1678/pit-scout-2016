//
//  AppDelegate.swift
//  DropboxPhotoTest
//
//  Created by Bryton Moeller on 12/30/15.
//  Copyright © 2015 citruscircuits. All rights reserved.
//

import UIKit
import Firebase
<<<<<<< HEAD
//import SwiftyDropbox
=======
import SwiftyDropbox
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


<<<<<<< HEAD
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        //Dropbox.setupWithAppKey("dekmb3lm9fzcd32")
        Instabug.start(withToken: "ab53034b6c6a246e5f5c74f489a49488", invocationEvent: IBGInvocationEvent.shake)
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        /*if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
                NotificationCenter.default.post(name: Notification.Name(rawValue: "dropbox_authorized"), object: nil)
            case .error(let error, let description):
                print("Error \(error): \(description)")
            }
        }*/
=======
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        FIRDatabase.database().persistenceEnabled = true
        Dropbox.setupWithAppKey("dekmb3lm9fzcd32")
        Instabug.startWithToken("ab53034b6c6a246e5f5c74f489a49488", invocationEvent: IBGInvocationEvent.Shake)
        return true
    }

    func application(app: UIApplication, openURL url: NSURL, options: [String : AnyObject]) -> Bool {
        
        if let authResult = Dropbox.handleRedirectURL(url) {
            switch authResult {
            case .Success(let token):
                print("Success! User is logged into Dropbox with token: \(token)")
                NSNotificationCenter.defaultCenter().postNotificationName("dropbox_authorized", object: nil)
            case .Error(let error, let description):
                print("Error \(error): \(description)")
            }
        }
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        
        return false
    }
    
<<<<<<< HEAD
    func applicationWillResignActive(_ application: UIApplication) {
=======
    func applicationWillResignActive(application: UIApplication) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

<<<<<<< HEAD
    func applicationDidEnterBackground(_ application: UIApplication) {
=======
    func applicationDidEnterBackground(application: UIApplication) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

<<<<<<< HEAD
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
=======
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
>>>>>>> 04784bb15bc29e5d700d0a18eb1f6a8cdd98e03f
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

