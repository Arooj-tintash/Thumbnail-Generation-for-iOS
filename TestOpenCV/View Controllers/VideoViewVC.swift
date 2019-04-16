//
//  VideoViewVC.swift
//  TestOpenCV
//
//  Created by Mac Mini on 16/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

import Foundation

import UIKit

class VideoViewVC: UIViewController {
    
    @IBOutlet weak var videoView : UIVideoEditorController!
    
    var image : UIVideoEditorController? = nil
    var video : Data? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _image = image {
//            videoView.videoPath = _image
            
        }
    }
    
    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
