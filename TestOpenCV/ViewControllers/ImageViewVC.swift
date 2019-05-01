//
//  ImageViewVC.swift
//  TestOpenCV
//
//  Created by Sajjad  on 04/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

import UIKit

class ImageViewVC: UIViewController {

    @IBOutlet weak var imageView : UIImageView!
    
    var image : UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _image = image {
            imageView.image = _image
            
        
            
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
