//
//  ZYPlayerTool.swift
//  ZYPlayer
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/26.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit
import AVFoundation

class ZYPlayerTool: NSObject {
    
   class public func playerHaveTracksWithURL(_ url:URL) ->Bool{
        let asset = AVURLAsset(url: url)
        let tracks = asset.tracks(withMediaType: .video)
        if tracks.count > 0  {
            return true
        }
        return false
    }
   class public func playerFristImageWithURL(_ url:URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let assetG = AVAssetImageGenerator(asset: asset)
        assetG.appliesPreferredTrackTransform = true
        assetG.apertureMode = AVAssetImageGenerator.ApertureMode.encodedPixels
        let time = CMTimeMakeWithSeconds(0.0, preferredTimescale: 600)
        var actualTime:CMTime = CMTimeMake(value: 10, timescale: 10)
        var videoImage:UIImage?
         do{
           let imageRef = try assetG.copyCGImage(at: time, actualTime: &actualTime)
          videoImage = UIImage(cgImage: imageRef)
       }catch {
           print("获取第一帧图片失败，可以设置一张默认的")
       }
       return videoImage
    }
   class public func playerVideoTotalTimeWithURL(_ url:URL) -> Float {
        let asset = AVURLAsset(url: url, options: [AVURLAssetPreferPreciseDurationAndTimingKey:false])
        let seconds = Float(asset.duration.value) / Float(asset.duration.timescale)
        return seconds
    }
   class public func playerConvertTime(_ second:Float) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(second))
        let dateFor = DateFormatter()
        dateFor.timeZone = TimeZone(identifier:"Asia/Shanghai")
        if (second / 3600) >= 1.0 {
            dateFor.dateFormat = "HH:mm:ss"
        }else {
             dateFor.dateFormat = "mm:ss"
        }
        
        return dateFor.string(from: date)
    }
    class func getBoundleImage(_ name:String) -> UIImage? {
        let bundlePath = Bundle.main.path(forResource: "PlayerView", ofType: "bundle")
        let bundle = Bundle.init(path: bundlePath!)
        let imageStr =  bundle?.path(forResource: name, ofType: "png")
        guard let value = imageStr else {
            return nil
        }
        return UIImage(named: value)
    }
    

}
