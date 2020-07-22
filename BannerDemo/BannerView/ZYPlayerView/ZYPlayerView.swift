//
//  ZYPlayerView.swift
//  ZYPlayer
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/5/8.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit
import AVFoundation

class ZYPlayerView: UIView {

    
    var coverImageView:UIImageView?
    
    private var contentView:UIView?
    private var loadingView:UIActivityIndicatorView?
    private var playOrPauseBtn:UIButton?
    private var leftTimeLabel:UILabel?
    private var rightTimeLabel:UILabel?
    private var bottomView:UIImageView?
    ///播放进度
    private var playScheduleSlider:UISlider?
    private var playerLayer:AVPlayerLayer?
    private var player:ZYPlayer?
    private var url:URL?
    private var timer:Timer?
    private var playStatus:PlayerState?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGesture()
        
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
//MARK: 设置UI
extension ZYPlayerView {
    private func setupUI() {
        self.contentView = UIView(frame: self.bounds)
        self.addSubview(contentView!)
        self.coverImageView = UIImageView(frame: self.bounds)
        self.coverImageView?.contentMode = .scaleToFill
        self.coverImageView?.image = ZYPlayerTool.getBoundleImage("play_bgIcon")
        self.addSubview(self.coverImageView!)
        self.loadingView = UIActivityIndicatorView(style: .gray)
        self.loadingView?.center = self.contentView!.center
        self.loadingView?.startAnimating()
        self.addSubview(self.loadingView!)
        setupBottomView()
    }
    private func setupBottomView() {
        let bottomView = UIImageView(frame: CGRect(x: 0, y: self.bounds.size.height - 50, width: self.bounds.size.width, height: 50))
        bottomView.image = ZYPlayerTool.getBoundleImage("play_bottom_shadow")
        bottomView.isUserInteractionEnabled = true
        self.bottomView = bottomView
        self.addSubview(bottomView)
        self.playOrPauseBtn = UIButton(type: .custom)
        self.playOrPauseBtn?.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        self.playOrPauseBtn?.addTarget(self, action: #selector(palyOrPauseClick(_:)), for: .touchUpInside)
        self.playOrPauseBtn?.setImage(ZYPlayerTool.getBoundleImage("play_icon"), for: .normal)
        self.playOrPauseBtn?.setImage(ZYPlayerTool.getBoundleImage("pause_icon"), for: .selected)
        self.playOrPauseBtn?.isSelected = true
        bottomView.addSubview(self.playOrPauseBtn!)
        
        self.leftTimeLabel = UILabel(frame: CGRect(x: 50, y: bottomView.frame.height / 2 - 10, width: 40, height: 20))
        self.leftTimeLabel?.textAlignment = .left
        self.leftTimeLabel?.textColor = .white
        self.leftTimeLabel?.font = UIFont.systemFont(ofSize: 11)
        self.leftTimeLabel?.text = ZYPlayerTool.playerConvertTime(0.0)
        bottomView.addSubview(self.leftTimeLabel!)
        self.rightTimeLabel = UILabel(frame: CGRect(x: bottomView.frame.width - 10 - 40, y: bottomView.frame.height / 2 - 10, width: 40, height: 20))
        self.rightTimeLabel?.textAlignment = .right
        self.rightTimeLabel?.textColor = .white
        self.rightTimeLabel?.font = UIFont.systemFont(ofSize: 11)
        self.rightTimeLabel?.text = ZYPlayerTool.playerConvertTime(0.0)
        bottomView.addSubview(self.rightTimeLabel!)
        let x:CGFloat = 50.0 + 40.0 
        let height = (bottomView.frame.height - 20.0) / 2
        let width = bottomView.frame.width - x - 40.0 - 10.0
        self.playScheduleSlider = UISlider(frame: CGRect(x: x, y: height, width: width, height: 20.0))
        self.playScheduleSlider?.backgroundColor = .clear
        self.playScheduleSlider?.minimumValue = 0.0
        self.playScheduleSlider?.setThumbImage(ZYPlayerTool.getBoundleImage("play_thumbImage"), for: .normal)
        self.playScheduleSlider?.isUserInteractionEnabled = false
        self.playScheduleSlider?.minimumTrackTintColor = .white
        self.playScheduleSlider?.maximumTrackTintColor = .lightGray
        bottomView.addSubview(self.playScheduleSlider!)
    }
}
//MARK: 其他
extension ZYPlayerView {
    
    private func setupGesture() {
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        singleTap.numberOfTapsRequired = 1
        singleTap.numberOfTouchesRequired = 1
        self.addGestureRecognizer(singleTap)
    }
    func playVideoWithUrl(_ url:URL) {
        self.player = ZYPlayer.default
        self.playerLayer = self.player?.playerPlayWithURL(url)
        self.playerLayer?.frame = self.bounds
        if self.playerLayer == nil {
            return
        }
        self.url = url
        self.contentView?.layer.addSublayer(self.playerLayer!)
        self.setupPlayStatus()
        self.setupPlayProgress()
        self.playBeforePlan()
    }
   private func playBeforePlan() {
        DispatchQueue.global().async {
            let coverImage = ZYPlayerTool.playerFristImageWithURL(self.url!)
            DispatchQueue.main.sync {
                self.coverImageView?.image = coverImage
            }
        }
    self.playerLayer?.videoGravity = .resizeAspect//.resizeAspectFill
        self.leftTimeLabel?.text = ZYPlayerTool.playerConvertTime(0.0)
        self.rightTimeLabel?.text = ZYPlayerTool.playerConvertTime(self.player?.videoTotalTime ?? 0.0)
       self.playScheduleSlider?.maximumValue = self.player?.videoTotalTime ?? 0.0
        self.playOrPauseBtn?.isSelected = true
    }
    private func setupPlayStatus() {
        self.player?.playStatusCallBack = { ( player:ZYPlayer , state:PlayerState?,errorCode:PlayerErrorCode?) in
            if state == nil {
                return
            }
            self.playStatus = state
            switch state {
            case .loading:
                self.startLoading()
                break
            case .playing:
                self.startPlay()
                break
            case .playEnd:
                self.playEnd()
                break
            case .playPause:
                break
            case .playStopped:
                self.playStopped()
                break
            default:
                break
            }
            
        }
    }
    private func startLoading() {
        self.loadingView?.isHidden = false
        self.loadingView?.startAnimating()
        self.playOrPauseBtn?.isSelected = false
    }
    private func startPlay() {
        self.loadingView?.stopAnimating()
        self.loadingView?.isHidden = true
        self.coverImageView?.isHidden = true
        self.playOrPauseBtn?.isSelected = true
        self.setupTimer()
        
    }
    private func playEnd() {
       self.loadingView?.stopAnimating()
       self.loadingView?.isHidden = true
       self.coverImageView?.isHidden = false
       self.playOrPauseBtn?.isSelected = false
       self.playScheduleSlider?.value = 0.0
       self.playStopped()
        self.leftTimeLabel?.text = ZYPlayerTool.playerConvertTime(0.0)
       if self.bottomView?.alpha == 0.0 {
         self.showControlView()
       }
    }
    func playStopped() {
        self.loadingView?.stopAnimating()
        self.loadingView?.isHidden = true
        self.coverImageView?.isHidden = false
        self.playOrPauseBtn?.isSelected = false
        self.playScheduleSlider?.value = 0.0
        self.player?.playStop()
        if self.bottomView?.alpha == 0.0 {
          self.showControlView()
        }
        
    }
    private func setupPlayProgress() {
        self.player?.playProgressCallBack = { ( player:ZYPlayer , progress:Float , currentTime:Float , durationTime:Float ) in
            self.leftTimeLabel?.text = ZYPlayerTool.playerConvertTime(currentTime)
            self.playScheduleSlider?.value = currentTime
            print("currentTime == \(currentTime)")
        }
        
    }
    private func replayPlay() {
        self.loadingView?.isHidden = false
        self.loadingView?.startAnimating()
        self.contentView?.isHidden = false
        self.playScheduleSlider?.value = 0.0
        self.playerLayer = self.player?.playerPlayWithURL(self.url!)
        self.playerLayer?.frame = self.bounds
        if self.playerLayer == nil {
           return
        }
       self.contentView?.layer.addSublayer(self.playerLayer!)
       self.playBeforePlan()
    }
    func pausePlay() {
       if self.playStatus == .playing  {
          self.player?.playerPause()
        }
    }
}

//MARK: 事件
extension ZYPlayerView {
    @objc private func palyOrPauseClick(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if self.playStatus == .playPause {
            self.player?.playerResume()
            return
        }
        if self.playStatus == .playing  {
            self.player?.playerPause()
            return
        }
        if (self.playStatus == .playEnd ||
            self.playStatus == .playStopped ){
            self.replayPlay()
        }
    }
    @objc private func handleSingleTap(_ sender:UITapGestureRecognizer) {
        if self.bottomView?.alpha == 0.0 {
            self.showControlView()
            return
        }
        self.hideControlView()
    }
    @objc private func dismissBottomView(_ timer:Timer) {
        if self.playStatus == .playing {
            self.hideControlView()
            self.invalidateTimer()
           return
       }
    }
    
    
    private func setupTimer() {
        self.invalidateTimer()
        self.timer = Timer(timeInterval: 5.0, target: self, selector: #selector(dismissBottomView(_:)), userInfo: nil, repeats: false)
        RunLoop.current.add(self.timer!, forMode: .common)
    }
    private func invalidateTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    private func showControlView() {
        self.setupTimer()
        UIView.animate(withDuration: 0.5) {
            self.bottomView?.alpha = 1.0
        }
    }
    private func hideControlView() {
        UIView.animate(withDuration: 0.5) {
            self.bottomView?.alpha = 0.0
        }
    }
    
}

