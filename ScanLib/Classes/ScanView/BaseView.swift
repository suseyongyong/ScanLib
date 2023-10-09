//
//  BaseView.swift
//  OoProject
//
//  Created by yuxilong on 2022/4/2.
//

import UIKit
import RxSwift

class BaseView: UIView {

    lazy var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initializeViews()
        initializeViewsLayout()
        initializeViewsAction()
//        requestData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        OOLogger.debug(.deinitM, message: String(describing: type(of: self)) + "." + #function)
    }
    
    /// 初始化控件 子类实现
    func initializeViews() {
        
    }
    
    /// 初始化控件布局 子类实现
    func initializeViewsLayout() {
        
    }
    
    /// 初始化控件Action 子类实现
    func initializeViewsAction() {
        
    }
    
    /// 请求数据 子类实现
    func requestData() {
        
    }
}
