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
        print(absURL);
        processImageFromOpenCV = OpenCVWrapper.processVideo(absURL as String);
//        do {
//            let data = try Data(contentsOf: url)
//        } catch let error {
//            print(error.localizedDescription)
//        }
        return processImageFromOpenCV
    }
    
    func getFrames(startTime: Int, thumbnailSize: CGSize, withAlreadyTrimmedURL trimmedURL: URL?, calculateNewFrequency frames:Int) -> UIImage{
        
        var imagesArr = [UIImage]()
        var lastImage = UIImage()
        
        let assetOptions = [AVURLAssetPreferPreciseDurationAndTimingKey : 1]
        let assetURL = trimmedURL
        guard let finalURL = assetURL else{
            return lastImage
        }
        let vidAsset = AVURLAsset(url: finalURL, options: assetOptions)
        let imageGenerator = AVAssetImageGenerator(asset: vidAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter = CMTime.zero
        imageGenerator.requestedTimeToleranceBefore = CMTime.zero
        imageGenerator.maximumSize = CGSize(width: thumbnailSize.width, height:  thumbnailSize.height)
        
        let durationSeconds = vidAsset.duration.seconds
        
        
//        var useNewFrequence = frames > 0
//        var frequencyToUse = Int32(useNewFrequence ? floor(Double(frames)/durationSeconds) : Double(4))
//        if frequencyToUse == 0 {
//            frequencyToUse = 4
//            useNewFrequence = false
//        }
//        let timeToFrameRatioFactor = 1.0/Double(frequencyToUse)
        
        let picsCnt = Double(frames) * durationSeconds
            //useNewFrequence ? Double(frames) : floor(durationSeconds / timeToFrameRatioFactor)
        print(picsCnt)
        for i in 0..<Int(picsCnt) {
            
            let timeFrame = CMTimeMake(value: Int64(i), timescale: Int32(picsCnt))
//            print(timeFrame.seconds)
           // print(vidAsset.duration.seconds, timeFrame.seconds)
            if (timeFrame.seconds > vidAsset.duration.seconds) {
                break
            }
            do {
                let halfWayImage = try imageGenerator.copyCGImage(at: timeFrame, actualTime: nil)
                let generatedImage = UIImage(cgImage: halfWayImage, scale: 1, orientation: .up)
                imagesArr.append(generatedImage)
            }
            catch {
                print("Unable to find thumbnail")
            }
        }
        lastImage = imagesArr[Int(picsCnt)-1]
        
        return lastImage
    }
    
}

