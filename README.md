# bannerView
## 说明
自己定义一款轮播Banner，支持网络图片、本地图片、gif图片、MP4视频 。

内部的pageControl和ZYPlayerView也可以拆开单独使用

目前支持几种类型

* 本地图片、网络图片、网络GIF混合
* 网络GIF图片和网络图片混合
* 网络图片和视频
* 网络GIF图片
* 网络图片
* 网络图片和视频

## 示例
![bannerExample](https://github.com/zhangyqyx/bannerView/blob/master/bannerExample.gif)

## 使用
1、本地图片、网络图片、网络GIF混合

```
 let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160))
     bannerView.imageDatas = ["https://img.ivsky.com/img/tupian/pre/201911/04/shumu_daoying.jpg",
        "WechatIMG105",
         "https://img.ivsky.com/img/tupian/t/201911/09/ciwei.jpg",
         "http://www.nbyh.info/uploadfiles/day_180315/201803151133523433.gif"]
    self.view.addSubview(bannerView)
```
2、网络图片和视频

```
 let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160))
     bannerView.pageControl?.directionType = .rightDirection
     bannerView.imageType = .bannerViewImageWithVideo
     bannerView.imageDatas = ["http://vfx.mtime.cn/Video/2019/02/04/mp4/190204084208765161.mp4",
           "https://img.ivsky.com/img/tupian/pre/201911/04/shumu_daoying.jpg",
            "https://img.ivsky.com/img/tupian/t/201911/09/ciwei.jpg"]
     self.view.addSubview(bannerView)
```
如果你发现有什么问题请联系我，我在不断改进 邮箱：zhangyqyx@163.com