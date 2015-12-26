//
//  UIButton+Extension.swift
//  Swift网易新闻
//
//  Created by 韩啸宇 on 15/12/26.
//  Copyright © 2015年 backy. All rights reserved.
//

import UIKit

extension UIButton {

    convenience  init(frame: CGRect, target:AnyObject?, action: Selector, tag: NSInteger, title: String) {
        self.init()
        
        self.frame = frame
        self.tag = tag
        
        setTitle(title, forState: UIControlState.Normal)
        setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        setTitleColor(UIColor.redColor(), forState: UIControlState.Selected)
        addTarget(target, action: action, forControlEvents: UIControlEvents.TouchUpInside)
    }
}