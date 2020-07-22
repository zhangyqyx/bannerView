//
//  ZYPlayer.swift
//  ZYPlayer
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/5/8.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit
import AVFoundation

enum PlayerErrorCode:Int {
    /// 正常播放
    case playerErrorCodeNoError  = 0
    /// 其他情况
    case playerErrorCodeOther    = 1
}
enum PlayerState:String {
    /// 加载中 缓存数据
    case loading = "loading"
    /// 播放中
    case playing = "playing"
    /// 播放结束
    case playEnd = "playEnd"
    /// 停止
    case playStopped = "playStopped"
    /// 暂停
    case playPause = "playPause"
    /// 播放错误
    case playError = "playError"
}


class ZYPlayer: NSObject {
    
    static let `default` = ZYPlayer()
    ///播放器
    var videoPlayer:AVPlayer?
    ///播放器Layer
    var videoPlayerLayer:AVPlayerLayer?
    ///播放时间
    var videoTotalTime:Float = 0.0
    ///播放状态回调
    var playStatusCallBack:((_ player:ZYPlayer ,_ state:PlayerState? ,_ errorCode:PlayerErrorCode?) -> Void)?
    ///播放进度回调
    var playProgressCallBack:((_ player:ZYPlayer ,_ progress:Float ,_ currentTime:Float ,_ durationTime:Float ) -> Void)?
    ///缓存状态回调
    var playLoadingCallBack:((_ player:ZYPlayer ,_ loadedProgress:Float ,_ complete:Bool) -> Void)?
    
    ///播放状态
    var playState:PlayerState = .playStopped {
        didSet {
           if oldValue == self.playState {
                return
            }
            if let callback = self.playStatusCallBack {
                callback(self,self.playState,self.errorCode)
            }
        }
    }
    ///错误
    private var errorCode:PlayerErrorCode = .playerErrorCodeNoError
    ///当前播放时间
    private var current:Float = 0.0
    ///播放进度 0~1
    private var progress:Float {
        get {
            if (self.videoTotalTime > 0) {
             return self.current / self.videoTotalTime
            }
            return 0.0
        }
    }
    ///缓冲进度 0~1
    private var loadedProgress:Float = 0.0 {
        didSet {
            if oldValue == self.loadedProgress {
                return
            }
            if self.loadedProgress == 1.0 || self.loadedProgress == 0.0 {
                return
            }
            if let callBack = self.playLoadingCallBack {
                callBack(self,self.loadedProgress , self.loadComplete)
            }
        }
    }
    private var playerItem:AVPlayerItem?
    ///是否暂停
    private var isPause:Bool = true
    ///是否缓存完成
    private var loadComplete:Bool = false
    private var kLoading = false
    private var timeObs:Any?
    private var isObserver = false
    
    deinit {
        self.releasePlayer()
    }
    
    func  playerPlayWithURL(_ url:URL) -> AVPlayerLayer? {
        if !ZYPlayerTool.playerHaveTracksWithURL(url) {
            self.errorCode = .playerErrorCodeOther
            self.playState = .playError
            return nil
        }
        
        self.playBeforePreparationWithURL(url)
        let urlAset = AVURLAsset(url: url)
        self.playerItem = AVPlayerItem(asset: urlAset)
        if self.videoPlayer != nil {
            self.videoPlayer?.replaceCurrentItem(with: self.playerItem)
        }else {
            self.videoPlayer = AVPlayer(playerItem: self.playerItem)
            self.videoPlayer?.usesExternalPlaybackWhileExternalScreenIsActive = true
        }
        self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
        self.setNotificationAndKvo()
        return self.videoPlayerLayer
    }
    func playerPause() {
        if self.playerItem == nil {
            return
        }
        self.isPause = true
        self.playState = .playPause
        self.videoPlayer?.pause()
    }
    func playerResume() {
       if self.playerItem == nil {
           return
       }
       self.isPause = false
       self.playState = .playing
       self.videoPlayer?.play()
    }
    func playStop() {
        self.videoPlayer?.seek(to: .zero, toleranceBefore: .zero, toleranceAfter: .zero, completionHandler: { (finished) in
            if !finished {
                return
            }
            self.isPause = true
            self.current = 0.0
            self.playState = .playStopped
            self.videoPlayer?.pause()
            self.videoPlayer = nil
            self.playerItem = nil
            self.releasePlayer()
            if let callBack = self.playProgressCallBack {
                callBack(self,self.progress,self.current , self.videoTotalTime)
            }
            
        })
    }

}
//MARK: 私有方法
extension ZYPlayer {
    private func playBeforePreparationWithURL(_ url:URL) {
       self.videoPlayer?.pause()
       self.releasePlayer()
       self.loadedProgress = 0.0
       self.current = 0.0
       self.isPause = false
       self.loadComplete = false
       self.videoTotalTime = ZYPlayerTool.playerVideoTotalTimeWithURL(url)
       
   }
   private func releasePlayer() {
    if isObserver {
        self.playerItem?.removeObserver(self, forKeyPath: "status")
          self.playerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
          self.playerItem?.removeObserver(self, forKeyPath: "playbackBufferEmpty")
          self.playerItem?.removeObserver(self, forKeyPath: "playbackLikelyToKeepUp")
         self.videoPlayer?.removeTimeObserver(self.timeObs as Any)
         self.timeObs = nil;
        self.isObserver = false
     }
        
    
   }
    private func setNotificationAndKvo() {
        self.isObserver = true
        self.playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "playbackBufferEmpty", options: .new, context: nil)
        self.playerItem?.addObserver(self, forKeyPath: "playbackLikelyToKeepUp", options: .new, context: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        
    }
    private func dealPlayWithItem(_ playerItem:AVPlayerItem?) {
        if playerItem == nil {
            return
        }
        self.videoPlayer?.play()
        self.timeObs =  self.videoPlayer?.addPeriodicTimeObserver(forInterval:
            CMTimeMake(value: 1, timescale: 1), queue: nil, using: { (time) in
                let current =  Float(playerItem!.currentTime().value) / Float(playerItem!.currentTime().timescale)
                 print("currentTime1233444 == \(current),  timescale =\(Float(playerItem!.currentTime().timescale))")
                if !self.isPause {
                    self.playState = .playing
                }
                if self.current == current {
                    return
                }
                self.current = current > self.videoTotalTime ? self.videoTotalTime : current
                if let callBack = self.playProgressCallBack {
                    callBack(self , self.progress , self.current,self.videoTotalTime)
                }

        })
    }
    private func loadedProgressWithItem(_ playerItem:AVPlayerItem?)  {
        let ranges = playerItem?.loadedTimeRanges.first?.timeRangeValue
        if  ranges == nil {
            return
        }
        let start = CMTimeGetSeconds(ranges!.start)
        let duration = CMTimeGetSeconds(ranges!.duration)
        let timeInterval = start + duration
        let durationTime = playerItem?.duration ?? CMTimeMake(value: 0, timescale: 0)
        let totalDuration = CMTimeGetSeconds(durationTime)
        self.loadedProgress = Float(timeInterval) / Float(totalDuration)
    }
    private func loadingSomeSecond() {
        if kLoading {
            return
        }
        kLoading = true
        self.videoPlayer?.pause()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
            self.kLoading = true
            if self.isPause  {
                return
            }
            self.videoPlayer?.play()
            if !(self.playerItem?.isPlaybackLikelyToKeepUp ?? false) {
                self.loadingSomeSecond()
            }
        }
        
    }
    
}
//MARK: 事件
extension ZYPlayer {
    @objc func appDidEnterBackground() {
        self.playState = .playPause
        self.isPause = true
        self.playerPause()
    }
    @objc func playerItemDidPlayToEnd(_ notification:Notification) {
        self.playState = .playEnd
        self.videoPlayer?.pause()
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        let playerItem = object as! AVPlayerItem
        if keyPath == "status" {
            if playerItem.status == .readyToPlay {
                self.dealPlayWithItem(playerItem)
            }else if playerItem.status == .failed ||
                     playerItem.status == .unknown{
                self.playState = .playError
                self.errorCode = .playerErrorCodeOther
                self.isPause = true
                self.videoPlayer?.pause()
                self.releasePlayer()
            }
            return
        }
        if keyPath == "loadedTimeRanges" {
            self.loadedProgressWithItem(playerItem)
            return
        }
        if keyPath == "playbackBufferEmpty" {
            if playerItem.isPlaybackBufferEmpty {
                self.playState = .loading
                ///提前缓存
                self.loadingSomeSecond()
            }
            return
        }
        if keyPath == "playbackLikelyToKeepUp" {
//        可以正常播放，相当于readyToPlay,可以进行其他操作
        }
        
    }
}
