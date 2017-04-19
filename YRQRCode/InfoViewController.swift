//
//  InfoViewController.swift
//  YRQRCode
//
//  Created by kilrae on 2017/4/19.
//  Copyright © 2017年 yang. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(_ sender: UIButton) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(image:didSavingWith:contentInfo:)), nil)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc fileprivate func image(image: UIImage, didSavingWith error: Error?, contentInfo: () -> Void) {
        if error != nil {
            let alertView = UIAlertController(title: error?.localizedDescription, message: "", preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: "ok", style: .cancel, handler: nil))
            present(alertView, animated: true, completion: nil)
        }
    }

}
