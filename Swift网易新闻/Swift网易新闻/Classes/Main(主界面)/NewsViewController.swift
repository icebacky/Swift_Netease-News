//
//  NewsViewController.swift
//  Swift网易新闻
//
//  Created by 韩啸宇 on 15/12/26.
//  Copyright © 2015年 backy. All rights reserved.
//

import UIKit

// MARK: - 需要的常量
private let navBarH: CGFloat = 64
private let titleScrollViewH: CGFloat = 44
private let transformScale: CGFloat = 1.3


class NewsViewController: UIViewController {

    /// 当前选中按钮
    private var selectedButton: UIButton?
    /// 存放所有按钮
    private var buttons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        view.addSubview(titleScrollView)
        view.addSubview(contentScrollView)

        setupAllChildVC()
        setupTitleButton()
        
        automaticallyAdjustsScrollViewInsets = false
    }
    
    
    // MARK: - 懒加载
    
    /// 标题视图
    private lazy var titleScrollView: UIScrollView = {

        let titleX: CGFloat = 0
        var titleY: CGFloat = (self.navigationController == nil) ? 0 : navBarH
        let titleW = screenW
        let titleH = titleScrollViewH
        
        let titleScrollView = UIScrollView()
        
        titleScrollView.frame = CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
        
        return titleScrollView
    }()
    
    /// 内容滚动视图
    private lazy var contentScrollView: UIScrollView = {
        
        let contentX: CGFloat = 0
        let contentY = CGRectGetMaxY(self.titleScrollView.frame)
        let contentW = screenW
        let contentH = screenH - contentY
        
        let contentScrollView = UIScrollView()
        
        contentScrollView.frame = CGRect(x: contentX, y: contentY, width: contentW, height: contentH)
        contentScrollView.backgroundColor = UIColor.lightGrayColor()
        
        contentScrollView.delegate = self
        contentScrollView.pagingEnabled = true
        
        return contentScrollView
    }()
    
    // MARK: - 初始化
    
    /**
     添加所有子控制器
     */
    private func setupAllChildVC() {
        addChildViewController(TopLineViewController(title: "头条"))
        addChildViewController(VideoViewController(title: "视频"))
        addChildViewController(SocietyViewController(title: "社会"))
        addChildViewController(SubscribeViewController(title: "订阅"))
        addChildViewController(ScienceViewController(title:"科技"))
    }
    
    /**
     添加标题按钮
     */
    private func setupTitleButton() {
        let buttonW: CGFloat = 100
        let buttonH = titleScrollViewH
        var buttonX: CGFloat = 0
        let buttonY: CGFloat = 0
        
        // 遍历所有子控制器
        let count = childViewControllers.count
        for var i = 0; i < count; i++ {
            let vc = childViewControllers[i]
            
            buttonX = CGFloat(i) * buttonW
            let buttonFrame = CGRect(x: buttonX, y: buttonY, width: buttonW, height: buttonH)
            
            guard let title = vc.title else {
                continue
            }
            
            let button = UIButton(frame: buttonFrame, target: self, action: Selector("buttonClick:"), tag: i, title: title)
            
            if i == 0 {
                buttonClick(button)
            }
            
            buttons.append(button)
            
            titleScrollView.addSubview(button)
        }
        
        // 标题和内容滚动视图的contentSize, 隐藏水平指示器
        titleScrollView.contentSize = CGSizeMake(buttonW * CGFloat(count), 0)
        titleScrollView.showsHorizontalScrollIndicator = false
        
        contentScrollView.contentSize = CGSizeMake(screenW * CGFloat(count), 0)
        contentScrollView.showsHorizontalScrollIndicator = false
    }
    
    /**
     按钮点击
     */
    @objc private func buttonClick(button: UIButton) {
        selectButton(button)
        
        let index = button.tag
        let offsetX = CGFloat(index) * screenW
        showVcView(offsetX)
        
        // 滚动到对应的view
        let offset = CGPoint(x: offsetX, y: contentScrollView.contentOffset.y)
        contentScrollView .setContentOffset(offset, animated: true)
    }
}

// MARK: - 控制器显示
extension NewsViewController {
    
    /**
     选中按钮
     */
    private func selectButton(button: UIButton) {
        // 还原上次选中按钮
        selectedButton?.selected = false
        selectedButton?.transform = CGAffineTransformIdentity
        
        // 记录选中按钮
        selectedButton = button
        button.selected = true

        // 选中按钮居中且放大
        setButtonAtCenter(button)
        button.transform = CGAffineTransformMakeScale(transformScale, transformScale)
        
    }
    
    /**
     让选中的按钮居中显示
     */
    private func setButtonAtCenter(button: UIButton) {
        // 设置标题滚动区域偏移量
        var offsetX = button.center.x - screenW * 0.5
    
        // 偏移量的最大最小值(最初和最末尾)
        let maxOffsetX = titleScrollView.contentSize.width - screenW
        let minOffsetX: CGFloat = 0
        // 开头和末尾的按钮不要居中, 不好看
        offsetX = offsetX < minOffsetX ? minOffsetX : offsetX
        offsetX = offsetX > maxOffsetX ? maxOffsetX : offsetX
        
        // 滚动区域
        titleScrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: true)
    }
    
    /**
     显示控制器view
     */
    private func showVcView(offsetX: CGFloat) {

        let index = NSInteger(offsetX / screenW)
        let showVc = childViewControllers[index]
        
        guard !showVc.isViewLoaded() else {
            return
        }
        
        let showX = CGFloat(index) * screenW
        let showY: CGFloat = 0
        let showW = screenW
        let showH = contentScrollView.frame.size.height
        
        showVc.view.frame = CGRectMake(showX, showY, showW, showH)
        
        contentScrollView.addSubview(showVc.view)
        contentScrollView.contentOffset = CGPoint(x: showX, y: contentScrollView.contentOffset.y)
    }
}

// MARK: - UIScrollViewDelegate
extension NewsViewController: UIScrollViewDelegate {

    // 停止减速后, 选中对应按钮, 添加对应控制器view
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // 获取最新偏移量
        let offsetX = scrollView.contentOffset.x
        
        // 当前滚动的页码
        let page = NSInteger(offsetX / screenW)
        
        // 选中按钮
        selectButton(buttons[page])
        
        // 跳转
        showVcView(offsetX)
    }

    // 监听scrollView的滚动
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // 获取偏移量
        let offsetX = scrollView.contentOffset.x
        
        // 偏左的按钮
        let indexL = NSInteger(offsetX / screenW)
        let leftButton = buttons[indexL]
        
        // 右边的按钮
        let indexR = indexL + 1
        let rightButton: UIButton? = indexR < buttons.count ? buttons[indexR] : nil
        
        let rightScale = offsetX / screenW - CGFloat(indexL)
        let leftScale = 1 - rightScale
        
        leftButton.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale * 0.3 + 1)
        rightButton?.transform = CGAffineTransformMakeScale(rightScale * 0.3 + 1, rightScale * 0.3 + 1)
        
        // 颜色渐变
        // 右边按钮 -> 黑色 -> 红色  R: 0 ~ 1
        let rightColor = UIColor(red: rightScale, green: 0, blue: 0, alpha: 1)
        let leftColor = UIColor(red: leftScale, green: 0, blue: 0, alpha: 1)
        rightButton?.setTitleColor(rightColor, forState: UIControlState.Normal)

        // 左边按钮 -> 红色 -> 黑色  R: 1 ~ 0
        leftButton.setTitleColor(leftColor, forState: UIControlState.Normal)
    }
}