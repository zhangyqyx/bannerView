//
//  BannerVideoViewCell.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/5/9.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit

class BannerVideoViewCell: UICollectionViewCell {
    
    /// 模型对象
    public var infoModel:BannerBaseDataInfo? {
        willSet {
            guard let dataInfo = newValue else {
                return
            }
            let url = URL(string: (dataInfo.imageUrl)!)
            self.playerView?.playVideoWithUrl(url!)
        }
    }
    /// 播放视图
    var playerView:ZYPlayerView?
    
    override init(frame: CGRect) {
          super.init(frame: frame)
          setupView()
      }
      
      required init?(coder: NSCoder) {
          fatalError("init(coder:) has not been implemented")
      }
      private func setupView() {
        let playerView = ZYPlayerView(frame: self.bounds)
        self.playerView = playerView
        self.contentView.addSubview(playerView)
      }
     func stopVideo() {
        self.playerView?.playStopped()
     }
    
    
}
