//
//  WelcomeViewController.swift
//  MyWayy
//
//  Created by ksglobal on 17/08/18.
//  Copyright © 2018 MyWayy. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var signUpButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpBackgroundLogin(mainView: self.view)
       self.navigationController?.navigationBar.isHidden = true
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
