//
//  ViewController.swift
//  ScanLib
//
//  Created by roger on 10/08/2023.
//  Copyright (c) 2023 roger. All rights reserved.
//

import UIKit
import ScanLib
import AVFoundation
class ViewController: UIViewController {
    
    lazy private var mainView: ScanView = {
        let mainView = ScanView()
        mainView.backgroundColor = .clear
        return mainView
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpView()
    }
    
    func setUpView(){
        mainView.scanner.delegate = self
        mainView.controller.delegate = self
        view.backgroundColor = .clear
        self.view.addSubview(mainView)
        mainView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ViewController:SFQRScanerProtocol{
    
    func SFQRScanerProcessFailed(_ scanner: SFQRScaner) {
        print("失败了")
    }
    
    func SFQRScanerInitilizationFailed(_ scanner: SFQRScaner) {
        print("初始化失败")
    }
    
    func SFQRScanerGainResult(_ scanner: SFQRScaner, _ result: String?) {
        guard let resultStr = result else {return}
        scanner.stop()
        debugPrint("------解析的二维码值-------\(resultStr)")
    }
}

extension ViewController:UINavigationControllerDelegate,UIImagePickerControllerDelegate {
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {[weak self]() in
            guard let weakSelf = self else { return  }
            DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                weakSelf.mainView.scanner.srart()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as? UIImage
        picker.dismiss(animated: true) {
            self.mainView.scanner.readFromImage(image!)
        }
    }
}
