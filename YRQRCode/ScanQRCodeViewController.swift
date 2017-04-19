//
//  ScanQRCodeViewController.swift
//  YRQRCode
//
//  Created by kilrae on 2017/4/14.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit
import AVFoundation
import Photos

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height
let scanWidth = screenWidth - 100
let scanHeight = scanWidth

class ScanQRCodeViewController: UIViewController {
    
    fileprivate var session: AVCaptureSession?
    fileprivate var previewLayer: AVCaptureVideoPreviewLayer?
    fileprivate lazy var imageView: UIImageView = UIImageView()
    fileprivate lazy var imagePickerVC: UIImagePickerController = UIImagePickerController()
    fileprivate var code: String?
    
    
    // MARK: - override function
    override func viewDidLoad() {
        super.viewDidLoad()
        requestCameraAuth()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - private function
    
    fileprivate func setupUI() {
        
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        // 创建会话
        session = AVCaptureSession()
        var input: AVCaptureDeviceInput?
        do {
            input = try AVCaptureDeviceInput(device: device)
            if let deviceInput = input {
                session?.addInput(deviceInput)
            }
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 设置扫描区域
            output.rectOfInterest = CGRect(x: 0.25, y: 50/screenWidth, width: scanHeight/screenHeight, height: scanWidth/screenWidth)
            session?.addOutput(output)
            // 设置元数据类型
            output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
            
            // 创建输出对象
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
            previewLayer?.frame = view.bounds
            if let layer = previewLayer {
                view.layer.addSublayer(layer)
            }
            
        } catch {
            debugPrint("error")
        }
        
        imageView.frame = CGRect(x: 50, y: self.view.bounds.height * 0.25, width: scanWidth, height: scanHeight)
        imageView.image = UIImage(named: "qrcode.png")
        view.addSubview(imageView)
        scanAnimation()
        
        let drawView = QRDrawView(frame: view.bounds)
        drawView.backgroundColor = UIColor.black
        drawView.alpha = 0.5
        view.addSubview(drawView)
        
        let photoButton = UIButton(type: .custom)
        photoButton.setTitle("相册", for: UIControlState())
        photoButton.setTitleColor(.white, for: UIControlState())
        photoButton.titleLabel?.textAlignment = .center
        photoButton.addTarget(self, action: #selector(openPhoto(_:)), for: .touchUpInside)
        photoButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        photoButton.frame = CGRect(x: 50, y: self.view.bounds.height * 0.25 + scanHeight + 30, width: 80, height: 50)
        drawView.addSubview(photoButton)
        
        let lightButton = UIButton(type: .custom)
        lightButton.setTitle("手电筒", for: UIControlState())
        lightButton.setTitleColor(.white, for: UIControlState())
        lightButton.titleLabel?.textAlignment = .center
        lightButton.addTarget(self, action: #selector(openLight(_:)), for: .touchUpInside)
        lightButton.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        lightButton.frame = CGRect(x: view.bounds.width - 130, y: self.view.bounds.height * 0.25 + scanHeight + 30, width: 80, height: 50)
        drawView.addSubview(lightButton)
        
        // 选定一块区域，设置不同的透明度
        let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
        let path2 = UIBezierPath(roundedRect: CGRect(x: CGFloat(50), y: view.layer.bounds.height * 0.25, width: scanWidth, height: scanHeight), cornerRadius: 0)
        path.append(path2.reversing())
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        drawView.layer.mask = shapeLayer
        self.startScan()
    }
    
    fileprivate func requestCameraAuth() {
        let status = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch status {
        case .authorized:
            setupUI()
        case .denied:
            let alert = UIAlertController(title: "提示", message: "您没有权限访问相机，请在设置中开启相机权限", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            let alert = UIAlertController(title: "提示", message: "请允许我们访问相机", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "允许", style: .default, handler: { [weak self] (action) in
                self?.setupUI()
            }))
            alert.addAction(UIAlertAction(title: "不允许", style: .cancel, handler: { [weak self] (action) in
                _ = self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        case .restricted:
            break
        }
    }
    
    fileprivate func requestPhotoAuth() {
        let status = PHPhotoLibrary.authorizationStatus()
        print(status)
        switch status {
        case .authorized:
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.delegate = self
            present(imagePickerVC, animated: true, completion: nil)
        case .denied:
            let alert = UIAlertController(title: "提示", message: "您没有权限访问相册，请在设置中开启相册权限", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        case .notDetermined:
            let alert = UIAlertController(title: "提示", message: "请允许我们访问相册", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "允许", style: .default, handler: { [weak self] (action) in
                self?.imagePickerVC.sourceType = .photoLibrary
                self?.imagePickerVC.delegate = self
                self?.present((self?.imagePickerVC)!, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "不允许", style: .cancel, handler: { [weak self] (action) in
                _ = self?.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        case .restricted:
            break
        }
    }
    
    /// 开始扫描
    fileprivate func startScan() {
        imageView.isHidden = false
        session?.startRunning()
    }
    
    /// 停止扫描
    fileprivate func stopScan() {
        imageView.isHidden = true
        session?.stopRunning()
    }
    
    /// 动画
    @objc private func scanAnimation() {
        let rect = CGRect(x: 50, y: view.bounds.height * 0.25 - scanHeight, width: scanWidth, height: scanHeight)
        imageView.frame = rect
        imageView.alpha = 0
        
        UIView.animate(withDuration: 1.5, delay: 0.0, options: UIViewAnimationOptions.repeat, animations: {
            self.imageView.alpha = 1
            self.imageView.frame = CGRect(x: 50, y: (self.view.bounds.height) * 0.25, width: scanWidth, height: scanHeight)
        }) { (finished) in
            
        }
    }
    
    /// 打开相册
    @objc fileprivate func openPhoto(_ sender: UIButton) {
        requestPhotoAuth()
    }
    
    /// 打开手电
    @objc fileprivate func openLight(_ sender: UIButton) {
        guard let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) else { return }
        do {
            try device.lockForConfiguration()
        } catch {
            
        }
        if device.torchMode == .on {
            device.torchMode = .off
        } else if device.torchMode == .off {
            device.torchMode = .on
        } else {
            device.torchMode = .on
        }
        device.unlockForConfiguration()
    }
    
    fileprivate func scanImage(image: UIImage) {
        var result: [String] = []
        if let tryImage = CIImage(image: image) {
            let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
            if let features = detector?.features(in: tryImage) {
                for feature in features {
                    if let string = (feature as? CIQRCodeFeature)?.messageString {
                        result.append(string)
                    }
                }
            }
        }
        code = result[0]
    }
    
    fileprivate func showAlert(title: String? = "success", message: String? = "") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "好的", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
extension ScanQRCodeViewController: AVCaptureMetadataOutputObjectsDelegate {
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        stopScan()
        if !metadataObjects.isEmpty {
            guard let obj = metadataObjects[0] as? AVMetadataMachineReadableCodeObject else {
                return
            }
            code = obj.stringValue
            let alert = UIAlertController(title: "Success", message: code, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default, handler: { [weak self] (action) in
                self?.startScan()
            }))
            present(alert, animated: true, completion: nil)
        }
    }
}

extension ScanQRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {

        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            scanImage(image: image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            scanImage(image: image)
        } else {
            
        }
        picker.dismiss(animated: true, completion: {
            self.showAlert(message: self.code)
        })
    }
}
