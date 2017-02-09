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
    func bold(text:String) -> NSMutableAttributedString {
        let attrs:[String:AnyObject] = [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 14)!]
        let boldString = NSMutableAttributedString(string:"\(text)", attributes:attrs)
        self.appendAttributedString(boldString)
        return self
    }
    
    func normal(text:String)->NSMutableAttributedString {
        let normal =  NSAttributedString(string: text)
        self.appendAttributedString(normal)
        return self
    }
}
