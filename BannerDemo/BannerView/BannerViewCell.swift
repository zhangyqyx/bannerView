//
//  BannerViewCell.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/24.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit

class BannerViewCell: UICollectionViewCell {
    /// 模型对象
    public var infoModel:BannerBaseDataInfo? {
        willSet {
            guard let dataInfo = newValue else {
                return
            }
            switch dataInfo.type {
            case .bannerImageInfoTypeLocality:
               self.loadImageView?.image = dataInfo.image ?? self.placeholderImage
                break
            case .bannerImageInfoTypeGIFImage:
                self.loadImageView?.image = self.placeholderImage
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
                     self.loadImageView?.image = dataInfo.image ?? self.placeholderImage
                }
                break
            default:
                self.loadImageView?.setImageWithURL(dataInfo.imageUrl, self.placeholderImage)
            }
        }
    }
    /// 图片显示方式
    public var imageContentMode:UIView.ContentMode = .scaleToFill {
        willSet {
            self.loadImageView?.contentMode = newValue
        }
    }
    /// 圆角
    public var imgCornerRadius:CGFloat = 0.0 {
        willSet {
            if newValue > 0.0 {
                let maskPath = UIBezierPath(roundedRect: (self.loadImageView?.bounds ?? CGRect.zero), cornerRadius: newValue)
                let maskLayer = CAShapeLayer()
                maskLayer.frame = self.bounds
                maskLayer.path = maskPath.cgPath
                self.loadImageView?.layer.mask = maskLayer
            }
        }
    }
    /// 占位图
    public var placeholderImage:UIImage?
    /// 是否裁剪，默认false
    public var isClips = false {
        willSet {
             self.loadImageView?.isClips = newValue
        }
    }
    
    private var loadImageView:LoadImageView?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupImageView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private func setupImageView() {
        let loadImageView = LoadImageView(frame: self.bounds)
        loadImageView.contentMode = self.contentMode
        loadImageView.isClips = self.isClips
        self.contentView.addSubview(loadImageView)
        self.loadImageView = loadImageView
    }
   
    
}
