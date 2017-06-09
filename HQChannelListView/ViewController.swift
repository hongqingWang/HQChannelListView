//
//  ViewController.swift
//  HQChannelListView
//
//  Created by 王红庆 on 2017/6/1.
//  Copyright © 2017年 王红庆. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var myChannels = ["推荐", "热点", "北京", "视频",
                      "社会", "娱乐", "问答", "汽车",
                      "财经", "军事", "体育", "段子",
                      "美女", "时尚", "国际", "趣图",
                      "健康", "特卖", "房产", "养生",
                      "历史", "育儿", "小说", "教育",
                      "搞笑"]
    var moreChannels = ["科技", "直播", "数码", "美食",
                        "电影", "手机", "旅游", "股票",
                        "科学", "动漫", "故事", "收藏",
                        "精选", "语录", "星座", "美图",
                        "政务", "辟谣", "火山直播", "中国新唱将",
                        "彩票", "快乐男生", "正能量"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("aaa")
        navigationItem.title = "王红庆"
        view.backgroundColor = UIColor.white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(popToChannelListViewController))
    }
    
    func popToChannelListViewController() -> () {

        let channelVC = HQChannelListViewController(myChannel: myChannels, moreChannel: moreChannels)
        channelVC.selectCallBack = { (myChannel, moreChannel, selectIndex) -> () in
            self.navigationItem.title = myChannel[selectIndex]
            self.myChannels = myChannel
            self.moreChannels = moreChannel
        }
        navigationController?.pushViewController(channelVC, animated: true)
    }
}

