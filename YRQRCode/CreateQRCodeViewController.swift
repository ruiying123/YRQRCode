//
//  CreateQRCodeViewController.swift
//  YRQRCode
//
//  Created by kilrae on 2017/4/14.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit
import Photos

class CreateQRCodeViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    
    fileprivate lazy var imagePickerVC: UIImagePickerController = {
        let vc = UIImagePickerController()
        vc.delegate = self
        return vc
    }()
    
    // MARK: - override function
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIButton function
    
    /// 选择图片
    @IBAction func choosePhoto(_ sender: UIButton) {
        requestPhotoAuth()
    }
    
    /// 生成二维码
    @IBAction func createQRCode(_ sender: UIButton) {
        let image = YRQRCode.generator(content: textField.text, size: 256, icon: imageView.image)
        print(image)
        if image != nil {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            guard let vc = storyBoard.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController else {
                return
            }
            vc.image = image
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    // MARK: - Private function
    
    /// 请求相册权限
    fileprivate func requestPhotoAuth() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            self.present(imagePickerVC, animated: true, completion: nil)
        case .denied:
            self.showAlert(title: "提示", message: "没有权限访问相册，请在设置中开启相册权限")
        case .notDetermined:
            let alert = UIAlertController(title: "提示", message: "请允许我们使用相册", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "允许", style: .default, handler: { [weak self] (action) in
                self?.present((self?.imagePickerVC)!, animated: true, completion: nil)
            }))
            alert.addAction(UIAlertAction(title: "不允许", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
        
    }
    
    fileprivate func showAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CreateQRCodeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        self.imageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }
}
