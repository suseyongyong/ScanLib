//
//  ScanView.swift
//  OoProject
//
//  Created by yong on 2023/7/26.
//

import UIKit
import AVFoundation
import SnapKit
import RxSwift


open class ScanView: BaseView {
    
public  let controller:UIImagePickerController = UIImagePickerController.init()
    //读取相册二维码图标
    public  var albumButtonStr:String? {
        didSet {
            if let albumButtonStr = albumButtonStr {
                self.albumButton.setImage(UIImage(named: albumButtonStr ), for: .normal)
            }
        }
    }
    //打开灯光图标
    public  var switchBtnStr:String? {
        didSet {
            if let switchBtnStr = switchBtnStr {
                self.switchBtn.setImage(UIImage(named: switchBtnStr), for: .normal)
            }
        }
    }

    lazy var topLeftView:UIView = {
        let topLeftView = UIView()
        topLeftView.backgroundColor = .white
        return topLeftView
    }()
    lazy var mainView:UIView = {
        let mainView = UIView()
        mainView.backgroundColor = .clear
        return mainView
    }()
    
    lazy var topRightView:UIView = {
        let topRightView = UIView()
        topRightView.backgroundColor = .white
        return topRightView
    }()
    
    lazy var leftView:UIView = {
        let leftView = UIView()
        leftView.backgroundColor = .white
        return leftView
    }()
    
    lazy var rightView:UIView = {
        let rightView = UIView()
        rightView.backgroundColor = .white
        return rightView
    }()
    
    
    lazy var bottomLeftView:UIView = {
        let bottomLeftView = UIView()
        bottomLeftView.backgroundColor = .white
        return bottomLeftView
    }()
    
    lazy var bottomRightView:UIView = {
        let bottomRightView = UIView()
        bottomRightView.backgroundColor = .white
        return bottomRightView
    }()
    
    lazy var bottomLView:UIView = {
        let bottomLView = UIView()
        bottomLView.backgroundColor = .white
        return bottomLView
    }()
    
    lazy var bottomRView:UIView = {
        let bottomRView = UIView()
        bottomRView.backgroundColor = .white
        return bottomRView
    }()
    
    lazy private var albumButton:UIButton = {
        let albumButton = UIButton.init(onlyImage: UIImage(named: "btn_album"))
        albumButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.albumButtonAction(albumButton)
            })
            .disposed(by: disposeBag)
        return albumButton
    }()
    
    lazy private var switchBtn:UIButton = {
        let switchBtn = UIButton.init(onlyImage: UIImage(named: "btn_open"))
        switchBtn.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let weakSelf = self else { return }
                weakSelf.switchBtnAction(switchBtn)
            })
            .disposed(by: disposeBag)
        return switchBtn
    }()
    
   public  var scanner:SFQRScaner = {
        let result:SFQRScaner = SFQRScaner.init()
        return result
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.loadUI()
        self.beginScaning()
        self.backgroundColor = .clear
        controller.sourceType = .savedPhotosAlbum
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadUI()  {
        self.addSubview(mainView)
        
        self.mainView.addSubview(topLeftView)
        self.mainView.addSubview(topRightView)
        self.mainView.addSubview(rightView)
        self.mainView.addSubview(leftView)
        
        self.mainView.addSubview(bottomLView)
        self.mainView.addSubview(bottomRView)
        self.mainView.addSubview(bottomRightView)
        self.mainView.addSubview(bottomLeftView)
        self.addSubview(albumButton)
        self.addSubview(switchBtn)
        
        mainView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.width.equalTo(mainView.snp.height)
            make.centerY.equalToSuperview()
        }
        
        topLeftView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(60)
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        topRightView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(60)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        leftView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(1)
            make.top.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        rightView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(1)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        bottomLeftView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(60)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        bottomRightView.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.width.equalTo(60)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        bottomLView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(1)
            make.bottom.equalToSuperview()
            make.leading.equalToSuperview()
        }
        
        bottomRView.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.width.equalTo(1)
            make.bottom.equalToSuperview()
            make.trailing.equalToSuperview()
        }
        
        albumButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-50)
        }
        switchBtn.snp.makeConstraints { make in
            make.top.equalTo(mainView.snp.bottom).offset(20)
            make.width.height.equalTo(50)
            make.centerX.equalToSuperview()
        }
    }
    
    
    private func beginScaning() -> Void {
        
        if AVCaptureDevice.authorizationStatus(for: .video) != .authorized {
            AVCaptureDevice.requestAccess(for: .video) { success in
                if success == true {
                    DispatchQueue.main.async {
                        self.scanner.setUp(self, nil)
                        self.scanner.srart()
                    }
                } else {
                    self.gotoSettingApp()
                }
            }
        } else {
            DispatchQueue.main.async {
                self.scanner.setUp(self, nil)
                self.scanner.srart()
            }
        }
    }
    
    private func gotoSettingApp() -> Void {
        guard UIApplication.shared.canOpenURL(URL.init(string: UIApplication.openSettingsURLString)!) else {
            return
        }
        UIApplication.shared.open(URL.init(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    
    func albumButtonAction(_ sender: Any) {
            scanner.stop()
        currentViewController()?.present(controller, animated: true)
        }
    func switchBtnAction(_ sender: UIButton) {
            
            sender.isSelected = !sender.isSelected
            openLight(open: sender.isSelected)
        }
        
        ///打开闪光灯的方法
        private func openLight(open:Bool){
            
            let device = AVCaptureDevice.default(for: .video)
            if device?.hasTorch == false {
            print("闪光灯坏了")
                return
                
            }
            
            if open {//打开
                
                try? device?.lockForConfiguration()
                device?.torchMode = .on
                device?.flashMode = .on
                device?.unlockForConfiguration()
                
                
            }else{//关闭闪光灯
                
                try? device?.lockForConfiguration()
                device?.torchMode = .off
                device?.flashMode = .off
                device?.unlockForConfiguration()
                
            }
            
        }
    
    
    // 当前控制器
    public func currentViewController() -> UIViewController? {
       var window = UIApplication.shared.keyWindow
       if window?.windowLevel != UIWindow.Level.normal{
         let windows = UIApplication.shared.windows
         for  windowTemp in windows{
           if windowTemp.windowLevel == UIWindow.Level.normal{
              window = windowTemp
              break
            }
          }
        }
       let vc = window?.rootViewController
       return currentVC(vc)
    }
//获取当前控制器
    public func currentVC(_ vc :UIViewController?) -> UIViewController? {
       if vc == nil {
          return nil
       }
       if let presentVC = vc?.presentedViewController {
          return currentVC(presentVC)
       }
       else if let tabVC = vc as? UITabBarController {
          if let selectVC = tabVC.selectedViewController {
              return currentVC(selectVC)
           }
           return nil
        }
        else if let naiVC = vc as? UINavigationController {
           return currentVC(naiVC.visibleViewController)
        }
        else {
           return vc
        }
     }
}
