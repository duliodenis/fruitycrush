//
//  MenuVC.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 2/8/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit
import AVFoundation

class MenuVC: UIViewController {

    var click: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSound()
    }
    
    
    func addSound() {
        // AudioPlayer for Button Click
        do {
            try click = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("click", ofType: "wav")!))
            click.prepareToPlay()
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    
    @IBAction func play(sender: AnyObject) {
        click.play()
        let gameVC = storyboard?.instantiateViewControllerWithIdentifier("GameViewController") as! GameViewController
        presentViewController(gameVC, animated: false, completion: nil)
    }

}
