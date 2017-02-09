//
//  ViewController.swift
//  DraftDay
//
//  Created by Kieran Andrews on 24/02/2016.
//  Copyright © 2016 Kieran Andrews. All rights reserved.
//

import UIKit
import LoginKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Do any additional setup after loading the view, typically from a nib.
        // Setup
//        LoginKitConfig.url = "http://tigerwolf.noip.me:4000/api/v1/"
        LoginKitConfig.url = "http://test.kieranandrews.com.au:4000/api/v1/"
//        LoginKitConfig.url = "http://direct.challengecup.club:8080/api/v1/"
        LoginKitConfig.loginPath = "sessions"
        LoginKitConfig.destination = { ()-> UIViewController in DraftController() }
        LoginKitConfig.logoImage = UIImage(named: "logo") ?? UIImage()
           
        Appearance.backgroundColor = UIColor(red: 0, green: 0.3255, blue: 0.5216, alpha: 1.0)
        
        let login_screen = LoginKit.loginScreenController() 
        self.present(login_screen, animated: false,completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

