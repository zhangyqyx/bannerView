//
//  BannerViewFlowLayout.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/24.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit

class BannerViewFlowLayout: UICollectionViewFlowLayout {

    /// 是否缩放
    public var isZoom:Bool = false
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    override func prepare() {
        super.prepare()
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let tmps = super.layoutAttributesForElements(in: rect)
        if !self.isZoom {
            return tmps
        }
        let centerX = (self.collectionView?.contentOffset.x ?? 0) + (self.collectionView?.bounds.size.width ?? 0) * 0.5
        if tmps == nil {
            return tmps
        }
        for attributes in tmps! {
            let centerDistance = abs(attributes.center.x - centerX)
            let scale = 1.0 / (1 + centerDistance * 0.001)
            attributes.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
        return tmps
    }
}
