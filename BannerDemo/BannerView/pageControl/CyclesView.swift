//
//  CyclesView.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/13.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit


class CyclesView: UIView {
    
    /// 线条宽度
    public var borderWith:CGFloat = 2
    /// 颜色
    public var fullColor:UIColor = .lightGray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        let ciclesRect = CGRect(x: rect.minX + borderWith , y: rect.minY + borderWith, width: rect.width - borderWith * 2, height: rect.height - borderWith * 2)
        let ctx = UIGraphicsGetCurrentContext()
        ctx?.setLineWidth(borderWith)
        ctx?.addEllipse(in: ciclesRect)
        ctx?.setStrokeColor(fullColor.cgColor)
        ctx?.strokePath();
     
    }


}
