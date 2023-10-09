//
//  SFQRScaner.swift
//  SFQRScaner
//
//  Created by Stroman on 2021/7/11.
//

import UIKit
import AVFoundation

public  protocol SFQRScanerProtocol:NSObjectProtocol {
    /// 二维码扫描器初始化失败了。
    /// - Parameter scanner: 二维码扫描器
    func SFQRScanerInitilizationFailed(_ scanner:SFQRScaner) -> Void
    /// 扫描完毕的结果是个字符串
    /// - Parameters:
    ///   - scanner: 二维码扫描器
    ///   - result: 扫描出来的结果，需要被回调出来。
    func SFQRScanerGainResult(_ scanner:SFQRScaner,_ result:String?) -> Void
    /// 二维码扫描器在处理过程中失败了
    /// - Parameter scanner: 扫描器
    func SFQRScanerProcessFailed(_ scanner:SFQRScaner) -> Void
}

open class SFQRScaner: NSObject,AVCaptureMetadataOutputObjectsDelegate {
    // MARK: - lifecycle
    deinit {
        print("\(type(of: self))释放了")
    }
    // MARK: - custom methods
    private func customInitilizer() -> Void {
    }
    
    private weak var contentView:UIView!
    private var target:CGRect?
    
    // MARK: - public interfaces
    ///  初始化
    /// - Returns: 空
    /// - Parameters:
    ///   - containerView: 容器视图
    ///   - ior: 有效扫描区域，空缺代表的是全面扫描
    internal func setUp(_ containerView:UIView,_ ior:CGRect?) -> Void {
        guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
            self.delegate?.SFQRScanerInitilizationFailed(self)
            return
        }
        self.device = AVCaptureDevice.default(for: .video)
        guard self.device != nil else {
            self.delegate?.SFQRScanerInitilizationFailed(self)
            return
        }
        do {
            try self.inputDevice = AVCaptureDeviceInput.init(device: self.device!)
        } catch {
            print(type(of: self),#function,error.localizedDescription)
            self.delegate?.SFQRScanerInitilizationFailed(self)
            return
        }
        self.session.canSetSessionPreset(.high)
        for iterator in self.session.inputs {
            self.session.removeInput(iterator)
        }
        guard self.session.canAddInput(self.inputDevice!) else {
            print(type(of: self),#function,"无法添加输入设备")
            self.delegate?.SFQRScanerInitilizationFailed(self)
            return
        }
        self.session.addInput(self.inputDevice!)
        for iterator in self.session.outputs {
            self.session.removeOutput(iterator)
        }
        guard self.session.canAddOutput(self.outputMeta) else {
            print(type(of: self),#function,"无法添加输入媒介")
            self.delegate?.SFQRScanerInitilizationFailed(self)
            return
        }
        self.session.addOutput(self.outputMeta)
        guard self.outputMeta.availableMetadataObjectTypes.contains(.qr) else {
            self.delegate?.SFQRScanerInitilizationFailed(self)
            return
        }
        if ior != nil {
            self.outputMeta.rectOfInterest = ior!
        }
        self.outputMeta.metadataObjectTypes = [.qr]
        self.outputMeta.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        self.previewLayer?.removeFromSuperlayer()
        self.previewLayer = AVCaptureVideoPreviewLayer.init(session: self.session)
        guard self.previewLayer != nil else {
            print(type(of: self),#function,"预览图层创建失败")
            self.delegate?.SFQRScanerInitilizationFailed(self)
            return
        }
        self.previewLayer?.videoGravity = .resizeAspectFill
        self.previewLayer?.frame = containerView.bounds
        containerView.layer.insertSublayer(self.previewLayer!, at: 0)
        contentView = containerView
        target = ior
    }
    
    /// 交给外界控制是否开始
    /// - Returns: 空
    public func srart() -> Void {
        
        if self.previewLayer == nil  {
            setUp(contentView, target)
        }
        
        guard self.previewLayer != nil else {
            return
        }

        DispatchQueue.global().async {
            self.session.startRunning()
        }
        self.isRunning = true
    }
    
    /// 交给外界控制是否停止识别
    /// - Returns: 空
    public  func stop() -> Void {
        self.session.stopRunning()
        self.isRunning = false
    }
    

    /// 从图片中读取二维码
    /// - Parameter image: 输入的图片
    /// - Returns: 读取的信息
    public func readFromImage(_ image:UIImage) {
        let targetImage:CGImage? = image.cgImage
        guard targetImage != nil else {
            self.delegate?.SFQRScanerProcessFailed(self)
            return
        }
        let detector:CIDetector? = CIDetector.init(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])
        guard detector != nil else {
            self.delegate?.SFQRScanerProcessFailed(self)
            return
        }
        let features:[CIFeature] = detector!.features(in: CIImage.init(cgImage: targetImage!))
        if features.count > 0 {
            let resultFeature:CIQRCodeFeature = features.first! as! CIQRCodeFeature
            self.delegate?.SFQRScanerGainResult(self, resultFeature.messageString)
        } else {
            self.delegate?.SFQRScanerGainResult(self, nil)
        }
    }
    // MARK: - actions
    // MARK: - accessors
    weak public var delegate:SFQRScanerProtocol?
    internal var isRunning:Bool = false/*正常情况下它并没有在运行*/
    private var device:AVCaptureDevice?
    private var inputDevice:AVCaptureDeviceInput?
    private var outputMeta:AVCaptureMetadataOutput = {
        let result:AVCaptureMetadataOutput = AVCaptureMetadataOutput.init()
        return result
    }()
    private var session:AVCaptureSession = {
        let result:AVCaptureSession = AVCaptureSession.init()
        return result
    }()
    private var previewLayer:AVCaptureVideoPreviewLayer?
    // MARK: - delegates
    public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count > 0 {
            let first:AVMetadataMachineReadableCodeObject = metadataObjects.first! as! AVMetadataMachineReadableCodeObject
            self.delegate?.SFQRScanerGainResult(self, first.stringValue)
        } else {
            self.delegate?.SFQRScanerGainResult(self, nil)
        }
    }
}
