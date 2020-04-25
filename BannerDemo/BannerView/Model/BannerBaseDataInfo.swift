//
//  BannerBaseDataInfo.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/24.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit

enum BannerImageInfoType:String {
    case bannerImageInfoTypeLocality = "bannerImageInfoTypeLocality" /// 本地图片
    case bannerImageInfoTypeNetIamge = "bannerImageInfoTypeNetIamge" /// 网络图片
    case bannerImageInfoTypeGIFImage = "bannerImageInfoTypeGIFImage" /// 网络GIF图片
}

class BannerBaseDataInfo: NSObject {
    /// 图片类型
    public var type:BannerImageInfoType?
    /// 图片
    public var image:UIImage?
    ///bannerView图片的类型
    public var bannerImageType:BannerViewImageType = .bannerViewImageTypeMix
    /// 地址
    public var imageUrl:String? {
        willSet {
            guard let imageName = newValue else {
                return
            }
            switch bannerImageType {
            case .bannerViewImageTypeGIFAndNet:
                if BannerTool.default.bannerIsGifWithURL(imageName) {
                    self.image = BannerTool.default.bannerGetGifImage(imageName)
                    self.type = .bannerImageInfoTypeGIFImage
                    return
                }
                self.type = .bannerImageInfoTypeNetIamge
                break
            case .bannerViewImageTypeLocality:
                self.type = .bannerImageInfoTypeLocality
                self.image = UIImage(named: imageName)
                break
            case .bannerViewImageTypeNetIamge:
                 self.type = .bannerImageInfoTypeNetIamge
                break
            case .bannerViewImageTypeGIFImage:
                self.image = BannerTool.default.bannerGetGifImage(imageName)
                self.type = .bannerImageInfoTypeGIFImage
                break
            default:
                if BannerTool.default.bannerImageIsLocation(imageName) {
                    self.type = .bannerImageInfoTypeLocality
                    self.image = UIImage(named: imageName)
                    return
                }else if BannerTool.default.bannerIsGifWithURL(imageName)  {
                   self.image = BannerTool.default.bannerGetGifImage(imageName)
                    self.type = .bannerImageInfoTypeGIFImage
                    return
                }
                self.type = .bannerImageInfoTypeNetIamge
            }
            
        }
    }
 
}
