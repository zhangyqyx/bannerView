//
//  BannerTool.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/14.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit
import MobileCoreServices

enum BannerImageType:String {
    /// 未知
    case bannerImageTypeUnknown = "bannerImageTypeUnknown"
    /// jpg
    case bannerImageTypeJpeg = "bannerImageTypeJpeg"
    /// png
    case bannerImageTypePng = "bannerImageTypePng"
    /// gif
    case bannerImageTypeGif = "bannerImageTypeGif"
    /// tiff
    case bannerImageTypeTiff = "bannerImageTypeTiff"
    /// webp
    case bannerImageTypeWebp = "bannerImageTypeWebp"
}


class BannerTool: NSObject {
    
    private var cacheFaileDictionary = Array<Any>()
    public let kCachePath = NSHomeDirectory() + "/Documents/KJLoadImages"
    static let `default` = BannerTool()
    
    func bannerValidUrl(_ url:String) -> Bool {
      let regex = "[a-zA-z]+://[^\\s]*"
      let predi = NSPredicate(format:"SELF MATCHES %@", regex)
        return predi.evaluate(with: url)
    
    }
    
    func bannerIsGifWithURL(_ imageUrl:String) -> Bool {
        let url = URL(string: imageUrl)
        do {
            let data = try  Data(contentsOf: url!)
            return contentTypeWithImageData(data: data) == .bannerImageTypeGif ? true : false
        } catch  {
            return false
        }
    }
    func bannerImageIsLocation(_ imageName:String) -> Bool {
        if imageName.hasPrefix("http") || imageName.hasPrefix("https") {
            return false
        }
        return true
    }
    func contentTypeWithImageData(data:Data) -> BannerImageType {
       var buffer = [UInt8](repeating: 0, count: 1)
        data.copyBytes(to: &buffer, count: 1)
        switch buffer {
            case [0xFF]:
                return .bannerImageTypeJpeg
            case [0x89]:
                return .bannerImageTypePng
            case [0x47]:
                return .bannerImageTypeGif
            case [0x49],[0x4D]:
                return .bannerImageTypeTiff
            case [0x52]:
               if let str = String(data: data[0...11], encoding: .ascii), str.hasPrefix("RIFF"), str.hasSuffix("WEBP") {
                    return .bannerImageTypeWebp
                }
            default:
                return .bannerImageTypeUnknown
        }
        return .bannerImageTypeUnknown
    }
    func bannerGetGifImage(_ imageUrl:String) -> UIImage? {
         let url = URL(string: imageUrl)
        do {
            let data = try Data(contentsOf: url!)
            let info: [String: Any] = [
                       kCGImageSourceShouldCache as String: true,
                       kCGImageSourceTypeIdentifierHint as String: kUTTypeGIF
                   ]
            guard let imageSource = CGImageSourceCreateWithData(
                NSData(data: data), info as CFDictionary) else {
                return nil
            }
            let imageCount = CGImageSourceGetCount(imageSource)
            var animatedImage:UIImage?
            var totalDuration:TimeInterval = 0
            if imageCount <= 1 {
                animatedImage = UIImage(data: data)
                return animatedImage
            }
            var images = [UIImage]()
           for i in 0 ..< imageCount {
                guard let imageRef = CGImageSourceCreateImageAtIndex(imageSource, i, info as CFDictionary) else {
                    return nil
                }
            animatedImage = UIImage(cgImage:imageRef , scale: UIScreen.main.scale, orientation: .up)
            images.append(animatedImage!)
                if imageCount == 1 {
                    totalDuration = Double.infinity
                } else{
                    guard let properties = CGImageSourceCopyPropertiesAtIndex(imageSource, i, nil)
                        as? [String: Any] else { return nil }

                    let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any]
                    totalDuration += getFrameDuration(from: gifInfo)
                }
            }
            animatedImage = UIImage.animatedImage(with: images, duration: totalDuration)
            return animatedImage
        } catch  {
            return nil
        }
    }
    private func getFrameDuration(from gifInfo: [String: Any]?) -> TimeInterval {
          let defaultFrameDuration = 0.1
          guard let gifInfo = gifInfo else { return defaultFrameDuration }
          let unclampedDelayTime = gifInfo[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber
          let delayTime = gifInfo[kCGImagePropertyGIFDelayTime as String] as? NSNumber
          let duration = unclampedDelayTime ?? delayTime
          
          guard let frameDuration = duration else { return defaultFrameDuration }
          return frameDuration.doubleValue > 0.011 ? frameDuration.doubleValue : defaultFrameDuration
    }
    
}
