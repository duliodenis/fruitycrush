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
    
    // Lazy Instantiation of the Theme Music
    lazy var themeMusic: AVAudioPlayer = {
        let url = NSBundle.mainBundle().URLForResource("Theme", withExtension: "mp3")
        let player = try? AVAudioPlayer(contentsOfURL: url!)
        player!.numberOfLoops = -1
        return player!
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSound()
        
        // and start playing the Theme Music
        themeMusic.play()
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
