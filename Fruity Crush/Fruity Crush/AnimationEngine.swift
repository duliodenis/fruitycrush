//
//  AnimationEngine.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 3/22/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import UIKit
import pop

class AnimationEngine {
    
    // Class Variables
    
    class var offScreenRightPosition: CGPoint {
        return CGPointMake(UIScreen.mainScreen().bounds.width, CGRectGetMidY(UIScreen.mainScreen().bounds))
    }
    
    class var offScreenLeftPosition: CGPoint {
        return CGPointMake(-UIScreen.mainScreen().bounds.width, CGRectGetMidY(UIScreen.mainScreen().bounds))
    }
    
    class var screenCenterPosition: CGPoint {
        return CGPointMake(CGRectGetMidX(UIScreen.mainScreen().bounds),
            CGRectGetMidY(UIScreen.mainScreen().bounds))
    }
    
    
    // Instance Variables
    
    var originalConstants = [CGFloat]()
    var constraints: [NSLayoutConstraint]!
    
    
    // Constants
    
    let ANIMATION_DELAY: Int = 1
    
    
    // MARK: Initialization
    
    init(constraints: [NSLayoutConstraint]) { // takes an array of constraints
        for constraint in constraints {
            // save the original constraints
            originalConstants.append(constraint.constant)
            // and replace with off screen value
            constraint.constant = AnimationEngine.offScreenRightPosition.x
        }
        
        self.constraints = constraints
    }
    
    
    // MARK: Animation
    
    func animateOnScreen(delay: Int) {
        // create a time delay
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(Double(delay) * Double(NSEC_PER_SEC)))
        
        // wait for the delay period then start animation
        dispatch_after(time, dispatch_get_main_queue()) {
            var index = 0
            repeat {
                let moveAnimation = POPSpringAnimation(propertyNamed: kPOPLayoutConstraintConstant)
                moveAnimation.toValue = self.originalConstants[index]
                moveAnimation.springBounciness = 12
                moveAnimation.springSpeed = 12
                
                // add some friction for the second and subsequent objects to drag a bit
                if (index > 0) {
                    moveAnimation.dynamicsFriction += 15 + CGFloat(index)
                }
                
                let constraint = self.constraints[index]
                constraint.pop_addAnimation(moveAnimation, forKey: "moveOnScreen")
                
                index++
            } while (index < self.constraints.count)
        }
    }
    
    
    class func animateToPosition(view: UIView, position: CGPoint, completion: ((POPAnimation!, Bool) -> Void)) {
        let moveAnimation = POPSpringAnimation(propertyNamed: kPOPLayerPosition)
        moveAnimation.toValue = NSValue(CGPoint: position)
        moveAnimation.springBounciness = 8
        moveAnimation.springSpeed = 8
        moveAnimation.completionBlock = completion
        view.pop_addAnimation(moveAnimation, forKey: "moveToPosition")
    }
}
