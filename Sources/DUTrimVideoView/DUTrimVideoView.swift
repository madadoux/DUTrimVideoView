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
public class DUTrimVideoView : UIView  {
    var asset : AVAsset!
    var imageFrameView : UIView!
    public var rangeSlider: DURangeSlider!
    public var delegate : VideoTrimViewDelegate?
    fileprivate func snapToSuperview(_ child: UIView) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            child.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            child.topAnchor.constraint(equalTo: self.topAnchor),
            child.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    public init(asset:AVAsset,frame:CGRect) {
        super.init(frame: frame)
        self.asset = asset
        
        imageFrameView = UIView()
        addSubview(imageFrameView)
        snapToSuperview(imageFrameView)
        
        imageFrameView.layer.cornerRadius = 5.0
        imageFrameView.layer.borderWidth  = 1.0
        imageFrameView.layer.borderColor  = UIColor.white.cgColor
        imageFrameView.layer.masksToBounds = true

      createRangeSlider()
        
        
    }
    func createRangeSlider()
    {
     

      rangeSlider = DURangeSlider()
      self.addSubview(rangeSlider)

      snapToSuperview(rangeSlider)

      rangeSlider.leftThumbImage = UIImage(named: "left")
      rangeSlider.rightThumbImage = UIImage(named: "right")
      rangeSlider.trackBorderTintColor = .white
      rangeSlider.trackBorderWidth = 4.0
      rangeSlider.tag = 1000
      
      //Range slider action
      rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
      
      let time = DispatchTime.now() + Double(Int64(NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
      DispatchQueue.main.asyncAfter(deadline: time) {
        self.rangeSlider.trackHighlightTintColor = UIColor.clear
        self.rangeSlider.curvaceousness = 1.0
        self.createImageFrames()
      }

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
      var startXPosition:CGFloat = 0.0
      
      //loop for 6 number of frames
      for _ in 0...5
      {
        
        let imageButton = UIButton()
        let xPositionForEach = CGFloat(imageFrameView.frame.width)/6
        imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(imageFrameView.frame.height))
        do {
          let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
          let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
          let image = UIImage(cgImage: img)
          imageButton.setImage(image, for: .normal)
          imageButton.imageView?.contentMode = .scaleAspectFit
        }
        catch
          _ as NSError
        {
          print("Image generation failed with error (error)")
        }
        
        startXPosition = startXPosition + xPositionForEach
        startTime = startTime + thumbAvg
        imageButton.isUserInteractionEnabled = false
        imageFrameView.addSubview(imageButton)
      }
      
    }
    
}
