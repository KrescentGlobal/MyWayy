//
//  OptionsWebViewController.swift
//  MyWayy
//
//  Created by SpinDance on 1/3/18.
//  Copyright © 2017 MyWayy. All rights reserved.
//

import UIKit
import WebKit

enum PresentedURL: String {
    case terms
    case connected
    
    func get() -> String {
        switch self {
        case .terms:
            guard let url = Bundle.main.url(forResource: "TermsOfUse", withExtension: "pdf", subdirectory: nil, localization: nil) else {
                return ""
            }
            return "\(url)"
        case .connected:
            return "http://www.connectednorth.io"
        }
    }
}

class OptionsWebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    var urlToPresent: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        loadWebView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadWebView() {
        guard let presentingURL = URL(string: urlToPresent) else {
            print("Error url")
            return
        }
        let requestObj = URLRequest(url: presentingURL)
        webView.load(requestObj)
    }
    
    @IBAction func back() {
        dismiss(animated: true, completion: nil)
    }
}
