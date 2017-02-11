//
//  NSMutableAttributedString+Additions.swift
//  DogruYanlis
//
//  Created by Başar Oğuz on 10/02/17.
//  Copyright © 2017 basaroguz. All rights reserved.
//

import Foundation
import UIKit

extension NSMutableAttributedString {
    func bold(_ text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 14)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.append(boldString)
        return self
    }
    
    func normal(_ text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.append(normal)
        return self
    }
}
