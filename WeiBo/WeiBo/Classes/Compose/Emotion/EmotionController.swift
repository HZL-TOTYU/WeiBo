//
//  EmotionController.swift
//  WeiBo
//
//  Created by 渠晓友 on 2017/6/9.
//  Copyright © 2017年 xiaoyouPrince. All rights reserved.
//

import UIKit

private let emotionCellID = "emotionCellID"

class EmotionController: UIViewController {
    
    
    // MARK: - 属性
    fileprivate lazy var collectionView : UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: CollectionViewEmotionLayout())
    fileprivate lazy var toolBar : UIToolbar = UIToolbar()
    

    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setupUI()
    }

}


// MARK: - 设置UI布局
extension EmotionController{
    
    fileprivate func setupUI() {
        
        // 添加
        self.view.addSubview(collectionView)
        self.view.addSubview(toolBar)
        collectionView.backgroundColor = UIColor.brown
        toolBar.backgroundColor = UIColor.darkGray

        // 手动布局
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        let views = ["tBar" : toolBar , "cView": collectionView ] as [String : Any]
        var cons = NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[tBar]-0-|", options: [], metrics: nil, views: views)
        cons += NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[cView]-0-[tBar]-0-|", options: [.alignAllLeft , .alignAllRight], metrics: nil, views: views)
        view.addConstraints(cons)
        
        // 准备Collection / ToolBar
        prepareForCollectionView()
        prepareForToolBar()
        
        
        
    }
    
    fileprivate func prepareForCollectionView(){
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier:emotionCellID)
        collectionView.dataSource = self
    }
    
    fileprivate func prepareForToolBar(){
        
        let titles = ["最近","表情"]
        var items = [UIBarButtonItem]()
        for title in titles {
            let item = UIBarButtonItem(title: title, style: .plain, target: self, action: #selector(toolBarItemClick(index:)))
            items.append(item)
        }
        toolBar.items = items
        toolBar.tintColor = UIColor.orange
    }
    
    @objc fileprivate func toolBarItemClick(index : Int){
        
    }

}

// MARK: - UICollectionViewDataSource
extension EmotionController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 100
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: emotionCellID, for: indexPath)
        cell.backgroundColor = indexPath.item % 2 == 0 ? UIColor.red : UIColor.gray
        return cell
    }
}


// MARK: - 自定义UICollectionViewFlowLayout布局
class CollectionViewEmotionLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        // 1. setupLayout
        let itemWH : CGFloat = UIScreen.main.bounds.size.width / 7
        itemSize = CGSize(width: itemWH, height: itemWH)
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .horizontal
        
        // 2.setupScrollView
        collectionView?.isPagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        let margin = (collectionView!.frame.size.height - 3 * itemWH) / 2
        let edgeInsets = UIEdgeInsets(top: margin, left: 0, bottom: margin, right: 0)
        collectionView?.contentInset = edgeInsets
    }
}

