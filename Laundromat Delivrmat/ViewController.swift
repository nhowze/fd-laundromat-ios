//
//  ViewController.swift
//  Laundromat Delivrmat
//
//  Created by Nicholas Howze on 7/24/18.
//  Copyright © 2018 ICI Technologies. All rights reserved.
//


import UIKit
import WebKit
import OneSignal

class ViewController: UIViewController, WKUIDelegate,UIWebViewDelegate, WKNavigationDelegate {
    var receivedURL: String?
    
    
    
    @IBOutlet weak var navBar: UINavigationBar!
    
    @IBOutlet weak var webView: WKWebView!
        @NSCopying  var webConfiguration = WKWebViewConfiguration()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if #available(iOS 13.0, *) {
                             
                             let customColor = UIColor(named: "Color")
                             
                     let navBarAppearance = UINavigationBarAppearance()
                     navBarAppearance.configureWithOpaqueBackground()
                     navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
                     navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
                     navBarAppearance.backgroundColor = customColor
                             navBar.standardAppearance = navBarAppearance
                     navBar.scrollEdgeAppearance = navBarAppearance
                 }
        
        NSLog("Load finished")
        let ds = WKWebsiteDataStore.default()
        let cookies = ds.httpCookieStore
        cookies.getAllCookies { (cookies: [HTTPCookie]) in
            var cookieDict = [String : AnyObject]()
            for cookie in cookies {
                NSLog("Saved cookie: \(cookie.name)")
                cookieDict[cookie.name] = cookie.properties as AnyObject?
            }
            UserDefaults.standard.set(cookieDict, forKey: "cookiez")
        }
        
         retrieve_cookies()
        
        // Status bar white font
        
        
        //   navBar.isHidden = true
        
        webView.uiDelegate = self
       webView.navigationDelegate = self
       
        
        WKWebViewConfiguration.cookiesIncluded{ [weak self] config in
            let webView = WKWebView(frame: .zero, configuration: (self?.webConfiguration)!)
            let urls = NSURL (string: "https://frontdoorlaundry.com/Laundromats/home.php");
        let requestObj = NSURLRequest(url: urls! as URL);
        webView.load(requestObj as URLRequest);
        }
        
        
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func opensite()
    {
        
        let urls = NSURL (string: "https://frontdoorlaundry.com/Laundromats/home.php");
        let requestObj = NSURLRequest(url: urls! as URL);
        webView.load(requestObj as URLRequest);
    }
    
  
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let ds = WKWebsiteDataStore.default()
        let cookies = ds.httpCookieStore
        cookies.getAllCookies { (cookies: [HTTPCookie]) in
            for cookie in cookies {
                NSLog("Known cookie at load: \(cookie.name)")
            }
        }
        NSLog("Starting to load")
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        NSLog("** Error" + error.localizedDescription)
    }
    
   
    
    func retrieve_cookies()
    {
        let ds = WKWebsiteDataStore.default()
        let cookies = ds.httpCookieStore
        let userDefaults = UserDefaults.standard
        if let cookieDict = userDefaults.dictionary(forKey: "cookiez") {
            NSLog("Retrieving cookies")
            var cookies_left = 0
            for (_, cookieProperties) in cookieDict {
                if let _ = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                    cookies_left += 1
                }
            }
            for (_, cookieProperties) in cookieDict {
                if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any] ) {
                    cookies.setCookie(cookie, completionHandler: {
                        cookies_left -= 1
                        NSLog("Retrieved cookie, \(cookies_left) to go")
                        if cookies_left == 0 {
                            self.opensite()
                        }
                    })
                }
            }
        } else {
            NSLog("No saved cookies")
            opensite()
        }
    }
    
    
    func webView(_ _webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil{
            //webView.load(navigationAction.request)
            UIApplication.shared.open(navigationAction.request.url!, options: [:])
            
            
        }
        return nil
        
    }
    

    
    
    @IBAction func printText(_ webView: WKWebView) {
        
        guard let urlCheck = webView.url
            else {return}
        
        
        
        
        let pi = UIPrintInfo.printInfo()
        pi.outputType = .general
        pi.jobName = urlCheck.absoluteString
        pi.orientation = .portrait
        pi.duplex = .longEdge
        
        let printController = UIPrintInteractionController.shared
        printController.printInfo = pi
     
        printController.printFormatter = webView.viewPrintFormatter()
        printController.present(animated: true) {(printController, success, error: Error?) -> Void in
            if success {
                
                print("successful print")
                print(success)
                webView.goBack()
            }else{
                
                print("cancel")
                webView.goBack()
                
            }
            
            
            
        }
        
       
        
    }
    

    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
        NSLog("Load finished")
        let ds = WKWebsiteDataStore.default()
        let cookies = ds.httpCookieStore
        cookies.getAllCookies { (cookies: [HTTPCookie]) in
            var cookieDict = [String : AnyObject]()
            for cookie in cookies {
                NSLog("Saved cookie: \(cookie.name)")
                cookieDict[cookie.name] = cookie.properties as AnyObject?
            }
            UserDefaults.standard.set(cookieDict, forKey: "cookiez")
            
                
                 let urlCheckStr = webView.url?.absoluteString
                
                
            if(urlCheckStr!.starts(with: "https://frontdoorlaundry.com/Laundromats/receipts.php?orderID=")){
                    
                    self.printText(webView);
              
                    
                        }
            
        }
        
        
       
        //push post start
        let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
        
        let userID = status.subscriptionStatus.userId
        print("userID = \(userID)")
        
        let pushToken = status.subscriptionStatus.pushToken
        print("pushToken = \(pushToken)")
        
        if pushToken != nil {
            if let playerID = userID{
                
                //Make POST call to your server with the user ID
                
                
                let request = NSMutableURLRequest(url: NSURL(string: "https://frontdoorlaundry.com/Laundromats/onesignalcatch.php")! as URL)
                request.httpMethod = "POST"
                let postString = "ID=\(playerID)"
                request.httpBody = postString.data(using: String.Encoding.utf8)
                
                let task = URLSession.shared.dataTask(with: request as URLRequest) {
                    data, response, error in
                    
                    if error != nil {
                        print("error=\(error)")
                        return
                    }
                    
                    print("response = \(response)")
                    
                    let responseString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)
                    print("responseString = \(responseString)")
                }
                task.resume();
                
                
                print("Current playerID \(playerID)")
                
                
            }
            
        }
        //push post end
        
        
    }
    
    @IBAction func refreshB(_ sender: UIButton) {
        
        webView.reload()
        
    }
    
    @IBAction func backB(_ sender: UIButton) {
        
        webView.goBack()
        
    }
    
    
    @IBAction func forwardB(_ sender: UIButton) {
        
        webView.goForward()
        
    }
    
    func loadURL(url: Any) {
        
        guard let URL = URL(string: url as! String)
            
            else { return }
        
        webView.load(URLRequest(url: URL))
        
    }
    
    
    func prompUserToRateApp(){
        
        if #available (iOS 10.3, *){
            //  SKStoreReviewController.requestReview()
            
            
        }
        
        
    }
    

    
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if navigationType == UIWebViewNavigationType.linkClicked {
            if (request.url?.host == "frontdoorlaundry.com"){
                //   navBar.isHidden = true
                return true
            } else {
                //    UIApplication.shared.openURL(request.url!)
                //     navBar.isHidden = false
                
                prompUserToRateApp()
                return true
            }
        }
        return true
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


extension WKWebViewConfiguration {
    /// Async Factory method to acquire WKWebViewConfigurations packaged with system cookies
    static func cookiesIncluded(completion: @escaping (WKWebViewConfiguration?) -> Void) {
        let config = WKWebViewConfiguration()
        guard let cookies = HTTPCookieStorage.shared.cookies else {
            completion(config)
            return
        }
        // Use nonPersistent() or default() depending on if you want cookies persisted to disk
        // and shared between WKWebViews of the same app (default), or not persisted and not shared
        // across WKWebViews in the same app.
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let waitGroup = DispatchGroup()
        for cookie in cookies {
            waitGroup.enter()
            dataStore.httpCookieStore.setCookie(cookie) { waitGroup.leave() }
        }
        waitGroup.notify(queue: DispatchQueue.main) {
            config.websiteDataStore = dataStore
            completion(config)
        }
    }
}
