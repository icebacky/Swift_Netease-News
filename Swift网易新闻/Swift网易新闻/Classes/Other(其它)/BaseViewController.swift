//
//  BaseViewController.swift
//  Swift网易新闻
//
//  Created by 韩啸宇 on 15/12/26.
//  Copyright © 2015年 backy. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

extension BaseViewController {

    convenience init(title: String) {
    
        self.init()
        self.title = title
    }
}