//
//  AppDelegate.swift
//  Laundromat Delivrmat
//
//  Created by Nicholas Howze on 7/24/18.
//  Copyright © 2018 ICI Technologies. All rights reserved.
//

import UIKit
import OneSignal
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
            loadHTTPCookies()
        Flurry.startSession("")
        UIApplication.shared.statusBarStyle = .lightContent
        
        
        //start one signal
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false, kOSSettingsKeyInAppLaunchURL: true]
        
        // Replace 'YOUR_APP_ID' with your OneSignal App ID.
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        
        // Recommend moving the below line to prompt for push after informing the user about
        //   how your app will use them.
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notifications: \(accepted)")
        })
        
       
        return true
    }
    
    
 

    
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        saveCookies()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        loadHTTPCookies()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        saveCookies()
    }
    
    func loadHTTPCookies() {
        
        if let cookieDict = UserDefaults.standard.value(forKey: "cookieArray") as? NSMutableArray {
            
            for c in cookieDict {
                
                let cookies = UserDefaults.standard.value(forKey: c as!String) as!NSDictionary
                let cookie = HTTPCookie(properties: cookies as![HTTPCookiePropertyKey: Any])
                
                HTTPCookieStorage.shared.setCookie(cookie!)
            }
        }
    }
    
    
    
    func saveCookies() {
        
        let cookieArray = NSMutableArray()
        if let savedC = HTTPCookieStorage.shared.cookies {
            for c: HTTPCookie in savedC {
                
                let cookieProps = NSMutableDictionary()
                cookieArray.add(c.name)
                cookieProps.setValue(c.name, forKey: HTTPCookiePropertyKey.name.rawValue)
                cookieProps.setValue(c.value, forKey: HTTPCookiePropertyKey.value.rawValue)
                cookieProps.setValue(c.domain, forKey: HTTPCookiePropertyKey.domain.rawValue)
                cookieProps.setValue(c.path, forKey: HTTPCookiePropertyKey.path.rawValue)
                cookieProps.setValue(c.version, forKey: HTTPCookiePropertyKey.version.rawValue)
                cookieProps.setValue(NSDate().addingTimeInterval(2629743), forKey: HTTPCookiePropertyKey.expires.rawValue)
                
                UserDefaults.standard.setValue(cookieProps, forKey: c.name)
                UserDefaults.standard.synchronize()
            }
        }
        
        UserDefaults.standard.setValue(cookieArray, forKey: "cookieArray")
    }
    
    
}

