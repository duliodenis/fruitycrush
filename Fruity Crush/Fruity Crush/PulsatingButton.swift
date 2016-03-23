//
//  PulsatingButton.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 3/22/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit
import pop

@IBDesignable
class PulsatingButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 4.0 {
        didSet {
            setupView()
        }
    }

    @IBInspectable var fontColor: UIColor = UIColor.whiteColor() {
        didSet {
            tintColor = fontColor
        }
    }
    
    override func awakeFromNib() {
        setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    
    func setupView() {
        layer.cornerRadius = cornerRadius
        
        addTarget(self, action: "scaleToSmall", forControlEvents: .TouchDown)
        addTarget(self, action: "scaleToSmall", forControlEvents: .TouchDragEnter)
        addTarget(self, action: "scaleAnimation", forControlEvents: .TouchUpInside)
        addTarget(self, action: "scaleToDefault", forControlEvents: .TouchDragExit)
    }
    
    
    // MARK: Animation Functions
    
    func scaleToSmall() {
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation.toValue = NSValue(CGSize: CGSizeMake(0.95, 0.95))
        layer.pop_addAnimation(scaleAnimation, forKey: "layerScaleSmallAnimation")
    }
    
    
    func scaleAnimation() {
        let scaleAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation.velocity = NSValue(CGSize: CGSizeMake(3.0, 3.0))
        scaleAnimation.toValue = NSValue(CGSize: CGSizeMake(1.0, 1.0))
        scaleAnimation.springBounciness = 18
        layer.pop_addAnimation(scaleAnimation, forKey: "layerScaleSpringAnimation")
    }
    
    
    func scaleDefault() {
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation.toValue = NSValue(CGSize: CGSizeMake(1.0, 1.0))
        layer.pop_addAnimation(scaleAnimation, forKey: "layerScaleDefaultAnimation")
    }
}
