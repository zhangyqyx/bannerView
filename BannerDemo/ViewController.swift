//
//  ViewController.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/13.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
    }

}
//MARK: 设置UI
extension ViewController {
    func setupUI() {
        
        let pageControl = PageControl(frame: CGRect(x: 0, y: 120, width: UIScreen.main.bounds.size.width, height: 10))
        pageControl.selectColor = .red
        pageControl.normalColor = .green
        pageControl.directionType = .rightDirection
        pageControl.pageMargin = 2
        pageControl.pointHeight = 10
        pageControl.selectWidth = 20
//        pageControl.pageType = .sizeDot
        pageControl.totalPages = 10
        pageControl.currentIndex = 3
        self.view.addSubview(pageControl)
    }
}


