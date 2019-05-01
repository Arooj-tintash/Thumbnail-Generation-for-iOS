//
//  ViewController.swift
//  TestOpenCV
//
//  Created by Sajjad  on 04/04/2019.
//  Copyright © 2019 TestOpenCV. All rights reserved.
//

import UIKit
import AVFoundation

class MainVC: UIViewController {

    @IBAction func photoTapped(_ sender: Any) {
        NSLog("TAPPED on image")
        let image = getImageFromBundle()
        performSegue(withIdentifier: "openImageSegue", sender: image)
    }

    @IBAction func videoTapped(_ sender: Any) {
        NSLog("TAPPED on video")
        let startingPoint = Date()
        let image = getVideoDataFromBundle()
        
        print("\(startingPoint.timeIntervalSinceNow * -1) seconds elapsed")
        
        performSegue(withIdentifier: "openImageSegue", sender: image)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier  == "openImageSegue"                 else { return }
        guard let image         = sender as? UIImage                else { return }
        guard let destination   = segue.destination as? ImageViewVC else { return }
        destination.image       = image
    }
}


extension MainVC {
    func getImageFromBundle() -> UIImage? {
        let imageArray = Bundle.main.paths(forResourcesOfType: "jpg", inDirectory: nil)
        var myImage : UIImage?  = nil
        var processImage : UIImage? = nil
        guard let urlString = imageArray.first else { return nil }
        let url = URL(fileURLWithPath: urlString)
        do {
            let data = try Data(contentsOf: url)
            myImage =  UIImage(data: data)
            processImage = OpenCVWrapper.processImage(myImage);
        } catch let error {
            print(error.localizedDescription)
            
        }
        return processImage
    }
    
    func getVideoDataFromBundle() -> UIImage? {
        let videoArray = Bundle.main.paths(forResourcesOfType: "mp4", inDirectory: nil)
        var processImageFromOpenCV : UIImage? = nil;
        guard let urlString = videoArray.first else { return nil }
        let url = URL(fileURLWithPath: urlString)
        let absURL = url.absoluteString as NSString
        
        processImageFromOpenCV = OpenCVWrapper.processVideo(absURL as String);
        
        return processImageFromOpenCV
    }
}

