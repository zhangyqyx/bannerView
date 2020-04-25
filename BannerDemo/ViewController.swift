//
//  ViewController.swift
//  BannerDemo
//
//  Created by ༺ོ࿆强ོ࿆ ༻ on 2020/4/13.
//  Copyright © 2020 ༺ོ࿆强ོ࿆ ༻. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    private var tableView:UITableView?
    private let kTableViewCell = "kTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
}
//MARK: 设置UI
extension ViewController {
    private func setupTableView() {
        let tableView = UITableView(frame: self.view.bounds, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: kTableViewCell)
        self.view.addSubview(tableView)
        self.tableView = tableView
    }
    private func setupBanner1() -> BannerView {
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160))
        bannerView.imageDatas = ["https://img.ivsky.com/img/tupian/pre/201911/04/shumu_daoying.jpg",
        "WechatIMG105",
         "https://img.ivsky.com/img/tupian/t/201911/09/ciwei.jpg",
         "http://www.nbyh.info/uploadfiles/day_180315/201803151133523433.gif"]
        return bannerView
    }
    
    private func setupBanner2() -> BannerView {
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160))
        bannerView.pageControl?.directionType = .rightDirection
        bannerView.pageControl?.pageType = .hollow
        bannerView.pageControl?.pointHeight = 10
        bannerView.pageControl?.selectColor = .red
        bannerView.pageControl?.normalColor = .green
        bannerView.imageViewContentMode = .scaleAspectFill
        bannerView.rollType = .leftToRight
        bannerView.imageDatas = ["https://img.ivsky.com/img/tupian/pre/201911/04/shumu_daoying.jpg",
        "WechatIMG105",
         "https://img.ivsky.com/img/tupian/t/201911/09/ciwei.jpg",
         "http://www.nbyh.info/uploadfiles/day_180315/201803151133523433.gif"]
        return bannerView
    }
    private func setupBanner3() -> BannerView {
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160))
        bannerView.pageControl?.pageType = .circle
        bannerView.pageControl?.pointHeight = 8
        bannerView.pageControl?.selectColor = .red
        bannerView.pageControl?.normalColor = .green
        bannerView.isZoom = true
        bannerView.imgCornerRadius = 10
        bannerView.itemWidth = 300
        bannerView.itemSpace = -10
        bannerView.imageDatas = ["https://img.ivsky.com/img/tupian/pre/201911/04/shumu_daoying.jpg",
        "WechatIMG105",
         "https://img.ivsky.com/img/tupian/t/201911/09/ciwei.jpg",
         "http://www.nbyh.info/uploadfiles/day_180315/201803151133523433.gif"]
        return bannerView
    }
    
    private func setupBanner4() -> BannerView {
        let bannerView = BannerView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 160))
        bannerView.pageControl?.pageType = .rectangle
        bannerView.pageControl?.pointHeight = 8
        bannerView.pageControl?.selectColor = .white
        bannerView.pageControl?.normalColor = .blue
        bannerView.isZoom = false
        bannerView.imgCornerRadius = 10
        bannerView.itemWidth = 360
        bannerView.itemSpace = 10
        bannerView.imageDatas = ["https://img.ivsky.com/img/tupian/pre/201911/04/shumu_daoying.jpg",
        "WechatIMG105",
         "https://img.ivsky.com/img/tupian/t/201911/09/ciwei.jpg",
         "http://www.nbyh.info/uploadfiles/day_180315/201803151133523433.gif"]
        return bannerView
    }
}



//MARK: 代理
extension ViewController:UITableViewDelegate,UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kTableViewCell, for: indexPath)
        if  indexPath.section == 0 {
            cell.contentView.addSubview(setupBanner1())
        }
        if  indexPath.section == 1 {
            cell.contentView.addSubview(setupBanner2())
        }
        if  indexPath.section == 2 {
            cell.contentView.addSubview(setupBanner3())
        }
        if  indexPath.section == 3 {
            cell.contentView.addSubview(setupBanner4())
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 10))
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
}


//MARK: BannerViewDelegate
extension ViewController:BannerViewDelegate {
    func bannerView(_ bannerView: BannerView, _ selectIndex: NSInteger) {
        print("selectIndex = \(selectIndex)")
    }
}



