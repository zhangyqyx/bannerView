
//
//  LoadImageView.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/14.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit
import CommonCrypto

public typealias DownLoadImageResult = (_ image:UIImage?) -> Void
public typealias DownLoadDataCallBack = (_ data:Data? ,_ error:NSError? ) -> Void
public typealias DownloadProgressResult = (_ total:Int64 , _ current:Int64 ) -> Void

class ImageDownloader: NSObject {
    
    private var section:URLSession?
    public  var task:URLSessionDownloadTask?
    private var totalLength:Int64 = 0
    private var currentLength:Int64 = 0
    private var progressCallBack:DownloadProgressResult?
    private var finishCallBack:DownLoadDataCallBack?
    
    func startDownloadImageWithUrl(_ url:String? , _ progress:@escaping DownloadProgressResult , _ complete:@escaping DownLoadDataCallBack) -> Void {
        self.progressCallBack = progress
        self.finishCallBack = complete
        if url == nil {
            return
        }
        if let requestUrl = URL(string: url!) {
            var request = URLRequest(url: requestUrl, cachePolicy: URLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 60)
            request.addValue("image/*", forHTTPHeaderField: "Accept")
            let config = URLSessionConfiguration.default
            let queue = OperationQueue()
            self.section = URLSession(configuration: config, delegate: self, delegateQueue: queue)
            self.task = self.section?.downloadTask(with: request)
            self.task?.resume()
            return
        }
        let error = NSError(domain: "zyq.com", code: 101, userInfo: ["errorMessage":"URL error"])
        complete(nil,error)
        return
    }
}
//MARK: 下载代理
extension ImageDownloader:URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let data = try Data(contentsOf: location)
            if self.progressCallBack != nil {
                self.progressCallBack!(self.totalLength , self.currentLength)
            }
            if self.finishCallBack != nil {
                self.finishCallBack!(data , nil)
                self.finishCallBack = nil
            }
            
        } catch  {
            
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        self.currentLength = totalBytesWritten
        self.totalLength = totalBytesExpectedToWrite
        if self.progressCallBack != nil {
            self.progressCallBack!(self.totalLength,self.currentLength)
        }
    }
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            if self.finishCallBack != nil {
                let error = NSError(domain: "zyq.com", code: 102, userInfo: ["errorMessage":error.debugDescription])
                self.finishCallBack!(nil ,error )
                self.finishCallBack = nil
            }
        }
        
    }
    
}

class LoadImageView: UIImageView {
    /// 下载完成回调
    var completionCallBack:DownLoadImageResult?
    /// 下载进度回调
    var progressCallBack:DownloadProgressResult?
    /// 重复下载次数
    private let failedTimes:Int = 2
    /// 是否裁剪尺寸
    public var isClips:Bool = false
    /// 下载图片者
    private var imageDownloader:ImageDownloader?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentMode = .scaleToFill
        self.isClips = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//MARK: 方法
extension LoadImageView {
  
    func setImageWithURL(_ url:String? ,_ placeholderImage:UIImage?) -> Void {
       setImageWithURL(url, placeholderImage, nil)
    }
    func setImageWithURL(_ url:String? ,_ placeholderImage:UIImage?,_ completion: DownLoadImageResult?) -> Void {
        guard let imageUrl = url else {
            return
        }
        self.image = placeholderImage
        self.completionCallBack = completion
        if !imageUrl.hasPrefix("http://") && !imageUrl.hasPrefix("https://"){
            if completion != nil {
                self.completionCallBack!(self.image)
            }
            return
        }
        let request = URLRequest(url: URL(string: imageUrl)!)
        DispatchQueue.global().async {
            self.downloadWithReqeust(request, holder: placeholderImage)
        }
        
    }
    private func downloadWithReqeust(_ theRequest:URLRequest , holder:UIImage?) {
        let cachedImage =  CacheImage.default.cacheImageForRequest(request: theRequest)
        if cachedImage != nil {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            if self.completionCallBack != nil {
                self.completionCallBack!(cachedImage)
            }
            return
        }
        DispatchQueue.main.async {
            self.image = holder
        }
        if CacheImage.default.failTimesForRequest(request: theRequest) >= self.failedTimes {
            return
        }
        self.cancelRequest()
        self.imageDownloader = nil
        let downloader = ImageDownloader()
        self.imageDownloader = downloader
        downloader.startDownloadImageWithUrl(theRequest.url?.absoluteString, { (total, current) in
            if let progressBlock = self.progressCallBack {
                 progressBlock(total,current)
            }
        }) {[weak self] (data, error) in
            if data != nil &&
                error == nil {
                var finalImage = UIImage(data: data!)
                if  finalImage != nil {
                    DispatchQueue.main.async {
                        if self?.isClips ?? false {
                            if abs((self?.frame.size.width ?? 0) - (finalImage?.size.width ?? 0)) != 0  &&
                                abs((self?.frame.size.height ?? 0) - (finalImage?.size.height ?? 0)) != 0{
                                finalImage = self?.clipImage(finalImage, self?.frame.size, true)
                            }
                        }
                    }
                    CacheImage.default.cacheImage(finalImage, request: theRequest)
                }else {
                    CacheImage.default.cacheFailRequest(request: theRequest)
                }
                DispatchQueue.main.async {
                    self?.image = finalImage
                }
                if self?.completionCallBack != nil {
                    self?.completionCallBack!(self?.image)
                }
                return
            }
            CacheImage.default.cacheFailRequest(request: theRequest)
            if self?.completionCallBack != nil {
                self?.completionCallBack!(self?.image)
            }
        }
        
    }
    
    ///清理掉请求
    func cancelRequest() {
        self.imageDownloader?.task?.cancel()
    }
    ///获取图片缓存的占用的总大小/bytes
    func imagesCacheSize() -> UInt64 {
        let dicPath = BannerTool.default.kCachePath
        var isDic = ObjCBool.init(false)
        var total:UInt64 = 0
        if  FileManager.default.fileExists(atPath: dicPath, isDirectory: &isDic) {
            if isDic.boolValue {
                do {
                    let files = try FileManager.default.contentsOfDirectory(atPath: dicPath)
                    for str in files {
                        let path = dicPath + "/\(str)"
                        let dict = try FileManager.default.attributesOfItem(atPath: path)
                        total += dict[FileAttributeKey.size] as! UInt64
                    }
                    
                } catch  {
                    return total
                }
               
            }
        }
        return total
        
    }
    ///清理图片缓存
    func clearImagesCache() {
        CacheImage.default.clearDiskCaches()
    }
    

    /// 等比例剪裁图片大小到指定的size
    /// - Parameters:
    ///   - image: 剪裁前的图片
    ///   - size: 图片大小
    ///   - isScaleToMax: 是否是最大比例，YES表示取最大比例
    func clipImage(_ image:UIImage? , _ size:CGSize? , _ isScaleToMax:Bool) -> UIImage? {
        if  image == nil || size == nil {
            return image
        }
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size!, false, scale)
        var aspectFitSize = CGSize.zero
        if image!.size.width != 0 && image!.size.height != 0 {
            let rateWidth = size!.width / image!.size.width
            let rateHeight = size!.height / image!.size.height
            let rate = isScaleToMax ? max(rateHeight, rateWidth) : min(rateHeight, rateWidth)
            aspectFitSize = CGSize(width: image!.size.width * rate, height: image!.size.height * rate)
            
        }
        image!.draw(in: CGRect(x: 0, y: 0, width: aspectFitSize.width, height: aspectFitSize.height))
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
        
    }

    
}
//MARK: 图片缓存
class CacheImage:NSObject {
    
    static let `default` = CacheImage()
    var cacheFaileDictionary:[String:String] = Dictionary()
    
    
    func clearDiskCaches() {
        let dicPath = BannerTool.default.kCachePath
        if FileManager.default.fileExists(atPath: dicPath, isDirectory: nil) {
            do {
                try  FileManager.default.removeItem(atPath: dicPath)
            } catch  {
                
            }
        }
        cacheFaileDictionary.removeAll()
    }
    func failTimesForRequest(request:URLRequest) -> Int64 {
        let faileTimes = self.cacheFaileDictionary[md5(strs: keyForRequest(request: request))]
        if let countStr = faileTimes {
            return Int64(countStr) ?? 0
        }
        return 0
    }
    
    func cacheImageForRequest(request:URLRequest) -> UIImage? {
       let dicPath = BannerTool.default.kCachePath
        let path = dicPath + "/" + md5(strs: keyForRequest(request: request))
        return UIImage(contentsOfFile: path)
    }
    
    func cacheFailRequest(request:URLRequest) {
        let key = md5(strs: keyForRequest(request: request))
        let faileTimes = self.cacheFaileDictionary[md5(strs: keyForRequest(request: request))]
        var times:Int64 = 0
        if let countStr = faileTimes {
            times = Int64(countStr) ?? 0
        }
       times += 1
       cacheFaileDictionary[key] = String(times)
    }
    func cacheImage(_ image:UIImage? , request:URLRequest?) {
        if image == nil ||
            request == nil {
            return
        }
         let dicPath = BannerTool.default.kCachePath
        if !FileManager.default.fileExists(atPath: dicPath, isDirectory: nil) {
            do {
                try FileManager.default.createDirectory(atPath: dicPath, withIntermediateDirectories: true, attributes: nil)
            } catch  {
                return
            }
        }
        let path = dicPath + "/" + md5(strs: keyForRequest(request: request!))
        let data = image?.pngData()
        if  let imageData = data {
            FileManager.default.createFile(atPath: path, contents: imageData, attributes: nil)
        }
    }
    
    private func keyForRequest(request:URLRequest) ->String {
        return (request.url?.absoluteString ?? "")
//        var portait = false
//        if UIDevice.current.orientation ==  .portrait {
//            portait = true
//        }
//        return (request.url?.absoluteString ?? "") + (portait ? "portait" : "lanscape")
    }
    private func md5(strs:String) ->String {
           let utf8_str = strs.cString(using: .utf8)
           let str_len = CC_LONG(strs.lengthOfBytes(using: .utf8))
           let digest_len = Int(CC_MD5_DIGEST_LENGTH)
           let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digest_len)
           CC_MD5(utf8_str, str_len, result)
           let str = NSMutableString()
           for i in 0..<digest_len {
               str.appendFormat("%02x", result[i])
           }
           result.deallocate()
           return str as String
    }
    
}
