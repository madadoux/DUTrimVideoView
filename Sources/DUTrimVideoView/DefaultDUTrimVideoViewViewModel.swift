//
//  File.swift
//  
//
//  Created by mohamed saeed on 16/09/2022.
//

import Foundation
import UIKit
import AVFoundation
open class DefaultDUTrimVideoViewViewModel: DUTrimVideoViewViewModelProtocol {
    public init() {}

    open func getFrameImages(trimView: DUTrimVideoView, atRange: ClosedRange<Double>) -> [UIImage] {
        var imgArray = [UIImage]()
        let asset = trimView.asset!
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter = CMTime.zero
        assetImgGenerate.requestedTimeToleranceBefore = CMTime.zero
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds = Int(CMTimeGetSeconds(thumbTime))
        let maxLength = "\(thumbtimeSeconds)" as NSString

        let thumbAvg = thumbtimeSeconds/6
        var startTime = 1
        let numberOFFrames = numberOfFrames(trimView: trimView)
        // loop for 6 number of frames
        for _ in 0 ... numberOFFrames {
            do {
                let time: CMTime = CMTimeMakeWithSeconds(Float64(startTime), preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                imgArray.append(image)
            }
            
            catch
            _ as NSError {
                print("Image generation failed with error (error)")
            }
          
            startTime = startTime + thumbAvg
        }
        return imgArray
    }
    
    open func numberOfFrames(trimView: DUTrimVideoView) -> Int {
        return 5
    }
}
