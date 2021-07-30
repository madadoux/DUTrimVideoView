//
//  TRTrimVideoView.swift
//  Video Trim Tool
//
//  Created by Mohamed saeed on 6/3/21.
//  Copyright © 2021 Faisal. All rights reserved.
//

import Foundation
import AVKit
public protocol VideoTrimViewDelegate {
    func rangeSliderValueChanged(trimView: DUTrimVideoView, rangeSlider: DURangeSlider)
    
}
public protocol  DUTrimVideoViewViewModel {
    func getFrameImages(trimView: DUTrimVideoView , atRange: ClosedRange<Double>) -> [UIImage]
    func  numberOfFrames ( trimView: DUTrimVideoView)-> Int

}
open class DefaultDUTrimVideoViewViewModel : DUTrimVideoViewViewModel{
    public init() {
        
    }
    open func getFrameImages(trimView: DUTrimVideoView , atRange: ClosedRange<Double>) -> [UIImage]
    {
        var imgArray = [UIImage]()
        let asset = trimView.asset!
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString

        let thumbAvg  = thumbtimeSeconds/6
        var startTime = 1
        let numberOFFrames = self.numberOfFrames(trimView: trimView)
        //loop for 6 number of frames
        for _ in 0...numberOFFrames
        {
          
          
          do {
            let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let image = UIImage(cgImage: img)
            imgArray.append(image)
          }
            
          catch
            _ as NSError
          {
            print("Image generation failed with error (error)")
          }
          
          startTime = startTime + thumbAvg
            
        }
        return imgArray
    }
    
    open func  numberOfFrames ( trimView: DUTrimVideoView)-> Int
    {
        return 5
    }
}

public class DUTrimVideoView : UIView  {
    var asset : AVAsset!
    var imageFrameView : UIView!
    public var rangeSlider: DURangeSlider!
    public var delegate : VideoTrimViewDelegate?
    public var viewModel : DUTrimVideoViewViewModel!
    fileprivate func snapToSuperview(_ child: UIView, constant: CGFloat) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: self.leadingAnchor,constant: constant),
            child.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -constant),
            child.topAnchor.constraint(equalTo: self.topAnchor),
            child.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    public init(asset:AVAsset,frame:CGRect,viewModel: DUTrimVideoViewViewModel = DefaultDUTrimVideoViewViewModel()) {
        super.init(frame: frame)
        self.asset = asset
        self.viewModel = viewModel
        imageFrameView = UIView()
        addSubview(imageFrameView)
        snapToSuperview(imageFrameView, constant: 10)

        imageFrameView.layer.cornerRadius = 5.0
        imageFrameView.layer.borderWidth  = 1.0
        imageFrameView.layer.borderColor  = UIColor.white.cgColor
        imageFrameView.layer.masksToBounds = true

        createRangeSlider()
        
        
    }
    open func recreateRangeSlider() {
        rangeSlider.removeFromSuperview()
        imageFrameView.removeFromSuperview()
        addSubview(imageFrameView)
        snapToSuperview(imageFrameView, constant: self.rangeSlider.thumbWidth/2)
        createRangeSlider()
    }
    
    func createRangeSlider()
    {
     

      rangeSlider = DURangeSlider()
      self.addSubview(rangeSlider)

        snapToSuperview(rangeSlider, constant: 0)

      rangeSlider.trackBorderTintColor = .white
      rangeSlider.trackBorderWidth = 4.0
      rangeSlider.tag = 1000
      
      //Range slider action
      rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        self.layoutIfNeeded()
        self.layoutSubviews()
      let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
     // DispatchQueue.main.asyncAfter(deadline: time) {
        self.rangeSlider.trackHighlightTintColor = UIColor.clear
        self.rangeSlider.curvaceousness = 1.0
        self.createImageFrames()
      //}

    }
    @objc func rangeSliderValueChanged(_ rangeSlider: DURangeSlider) {
        delegate?.rangeSliderValueChanged(trimView: self, rangeSlider: rangeSlider)
    }
   public  required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   public func createImageFrames()
    {
      //creating assets
     
//      let maxLength         = "\(thumbtimeSeconds)" as NSString
    guard  let asset = asset else {
        return
    }
       var startXPosition:CGFloat = 0.0
       let frames = viewModel.getFrameImages(trimView: self, atRange: 0.0 ... asset.duration.seconds)
      //loop for 6 number of frames
      for i in 0..<frames.count
      {
        
        let imageButton = UIButton()
        let xPositionForEach = CGFloat(imageFrameView.frame.width)/6
        imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(imageFrameView.frame.height))
        let image = frames[i]
          imageButton.setImage(image, for: .normal)
          imageButton.imageView?.contentMode = .scaleAspectFit
      
        startXPosition = startXPosition + xPositionForEach
        imageButton.isUserInteractionEnabled = false
        imageFrameView.addSubview(imageButton)
      }
      
    }
    
}




