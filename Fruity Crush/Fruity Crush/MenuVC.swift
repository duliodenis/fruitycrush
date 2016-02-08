//
//  MenuVC.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 2/8/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit

class MenuVC: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func play(sender: AnyObject) {
        let gameVC = storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        presentViewController(gameVC, animated: true, completion: nil)
    }

}
