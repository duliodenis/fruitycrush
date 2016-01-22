//
//  Extensions.swift
//  Fruity Crush
//
//  Created by Dulio Denis on 1/21/16.
//  Copyright © 2016 Dulio Denis. All rights reserved.
//

import Foundation

extension Dictionary {
// entend Dictionary to load JSON from the MainBundle
    
    static func loadJSONFromBundle(filename: String) -> Dictionary<String, AnyObject>? {
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            var data: NSData?
            
            do {
                data = try NSData(contentsOfFile: path, options:NSDataReadingOptions())
                var dictionary: Dictionary<String, AnyObject>? = nil
                
                do {
                    dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? Dictionary<String, AnyObject>
                    return dictionary
                } catch {
                    print("Could not load JSON level file: \(filename)")
                }
                
            } catch {
                print("Could not find level file: \(filename)")
            }
        }
        
        return nil
    }
}