//
//  ViewController.swift
//  HybridApp
//
//  Created by Sean on 2/21/15.
//  Copyright (c) 2015 Sean. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate {

  @IBOutlet weak var mWebview: UIWebView!
  @IBOutlet weak var mSegmentControl: UISegmentedControl!
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    var htmlfile = NSBundle.mainBundle().pathForResource("index", ofType: "html", inDirectory: "WebContent")
    var htmlfileUrl = NSURL(fileURLWithPath: htmlfile!)
    
//    mWebview.loadHTMLString("<h1>Hello HybridApp</h1>", baseURL: nil)
    mWebview.loadRequest(NSURLRequest(URL: htmlfileUrl!))
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func onValueChanged(sender: AnyObject) {
    println(">> onValueChanged")
    var selection = (sender as UISegmentedControl).selectedSegmentIndex
//    var img = UIImage(named: "WebContent/img1.png")
    var img = selection == 0 ? "img0.png" : "img1.png"
    
    var jsCode = "replaceImg('" + img + "')" // JS code: replaceImg('img2.png')
    self.mWebview.stringByEvaluatingJavaScriptFromString(jsCode)
  }
  
  let CUSTOM_SCHEME = "uiwebview"
  func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
    println(">>shouldStartLoadWithRequest")
    
    var url = request.URL
    if let scheme = url.scheme {
      if scheme.lowercaseString == CUSTOM_SCHEME {
        var host = url.host // hierarchical part, not used
//        var user = url.user;
//        var password = url.password;
//        var path = url.path;
//        var fragment = url.fragment;
//        var relativePath = url.relativePath;
//        println("user: \(user) password: \(password) path: \(path) fragment: \(fragment) relativePath: \(relativePath)")
        
        var queryString = url.query!
        var img = queryString.componentsSeparatedByString("=")[1]
        self.mSegmentControl.selectedSegmentIndex = img == "img0.png" ? 1 : 0
        self.onValueChanged(self.mSegmentControl)

        return false
      }
    }

    return true
  }
}

