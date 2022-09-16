//
//  TRTrimVideoView.swift
//  Video Trim Tool
//
//  Created by Mohamed saeed on 6/3/21.
//  Copyright © 2021 Faisal. All rights reserved.
//

import AVKit
import Foundation
public protocol VideoTrimViewDelegate {
    func rangeSliderValueChanged(trimView: DUTrimVideoView, rangeSlider: DURangeSlider)
}

public protocol DUTrimVideoViewViewModelProtocol {
    func getFrameImages(trimView: DUTrimVideoView, atRange: ClosedRange<Double>) -> [UIImage]
    func numberOfFrames(trimView: DUTrimVideoView) -> Int
}

public class DUTrimVideoView: UIView {
    var asset: AVAsset!
    var imageFrameView: UIView!
    public var rangeSlider: DURangeSlider!
    public var delegate: VideoTrimViewDelegate?
    public var viewModel: DUTrimVideoViewViewModelProtocol!
    fileprivate func snapToSuperview(_ child: UIView, constant: CGFloat) {
        child.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            child.leadingAnchor.constraint(equalTo: leadingAnchor, constant: constant),
            child.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -constant),
            child.topAnchor.constraint(equalTo: topAnchor),
            child.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    public init(asset: AVAsset, frame: CGRect, viewModel: DUTrimVideoViewViewModelProtocol = DefaultDUTrimVideoViewViewModel()) {
        super.init(frame: frame)
        self.asset = asset
        self.viewModel = viewModel
        imageFrameView = UIView()
        addSubview(imageFrameView)
        snapToSuperview(imageFrameView, constant: 10)

        imageFrameView.layer.cornerRadius = 5.0
        imageFrameView.layer.borderWidth = 1.0
        imageFrameView.layer.borderColor = UIColor.blue.cgColor
        imageFrameView.layer.masksToBounds = true

        createRangeSlider()
    }

    open func recreateRangeSlider() {
        rangeSlider.removeFromSuperview()
        imageFrameView.removeFromSuperview()
        addSubview(imageFrameView)
        snapToSuperview(imageFrameView, constant: rangeSlider.thumbWidth/2)
        createRangeSlider()
    }
    
    func createRangeSlider() {
        rangeSlider = DURangeSlider()
       
        addSubview(rangeSlider)

        snapToSuperview(rangeSlider, constant: 0)

        rangeSlider.trackBorderTintColor = .white
        rangeSlider.trackBorderWidth = 4.0
        rangeSlider.tag = 1000
      
        // Range slider action
        rangeSlider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        layoutIfNeeded()
        layoutSubviews()
        rangeSlider.trackHighlightTintColor = UIColor.clear
        rangeSlider.curvaceousness = 1.0
        createImageFrames()
    }

    @objc func rangeSliderValueChanged(_ rangeSlider: DURangeSlider) {
        delegate?.rangeSliderValueChanged(trimView: self, rangeSlider: rangeSlider)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func createImageFrames() {
        // creating assets
     
        guard let asset = asset else {
            return
        }
        var startXPosition: CGFloat = 0.0
        let frames = viewModel.getFrameImages(trimView: self, atRange: 0.0 ... asset.duration.seconds)
        // loop for 6 number of frames
        for i in 0 ..< frames.count {
            let imageButton = UIButton()
            let xPositionForEach = CGFloat(imageFrameView.frame.width)/6
            imageButton.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(imageFrameView.frame.height))
            let image = frames[i]
            imageButton.setImage(image, for: .normal)
            imageButton.imageView?.contentMode = .scaleAspectFill
      
            startXPosition = startXPosition + xPositionForEach
            imageButton.isUserInteractionEnabled = false
            imageFrameView.addSubview(imageButton)
        }
    }
}
