//
//  RangeSlider.swift
//  CustomSliderExample
//
//  Created by William Archimede on 04/09/2014.
//  Copyright (c) 2014 HoodBrains. All rights reserved.
//
import Foundation
import UIKit
import QuartzCore

class DURangeSliderTrackLayer: CALayer {
    weak var rangeSlider: DURangeSlider?
    
    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        
        // Clip
        let cornerRadius = bounds.height * slider.curvaceousness / 2.0
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        ctx.addPath(path.cgPath)
        
        // Fill the track
        ctx.setFillColor(slider.trackTintColor.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
        
        // Fill the highlighted range
        ctx.setFillColor(slider.trackHighlightTintColor.cgColor)
        let lowerValuePosition = CGFloat(slider.positionForValue(slider.lowerValue))
        let upperValuePosition = CGFloat(slider.positionForValue(slider.upperValue))
        let rect = CGRect(x: lowerValuePosition, y: 0.0, width: upperValuePosition - lowerValuePosition, height: bounds.height)
        ctx.fill(rect)
        //Outline
        ctx.setStrokeColor(rangeSlider!.trackBorderTintColor.cgColor)
        ctx.setLineWidth(CGFloat(rangeSlider!.trackBorderWidth))
        ctx.addPath(UIBezierPath(rect: rect.insetBy(dx: 0, dy: 2)).cgPath)
        ctx.strokePath()
    }
}

class TRRangeSliderThumbLayer: CALayer {
    
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    weak var rangeSlider: DURangeSlider?
    
    var strokeColor: UIColor = UIColor.gray {
        didSet {
            setNeedsDisplay()
        }
    }
    var lineWidth: CGFloat = 0.5 {
        didSet {
            setNeedsDisplay()
        }
    }
    var fillImage : CGImage?
    
    override func draw(in ctx: CGContext) {
        guard let slider = rangeSlider else {
            return
        }
        
        let thumbFrame = bounds.insetBy(dx: 2.0, dy: 2.0)
        let cornerRadius = thumbFrame.height * slider.curvaceousness / 2.0
        let thumbPath = UIBezierPath(roundedRect: thumbFrame, cornerRadius: cornerRadius)
        
        if fillImage != nil {
            ctx.draw(fillImage!, in: bounds)
        }
            
        else {
            // Fill
            ctx.setFillColor(slider.thumbTintColor.cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
            // Outline
            ctx.setStrokeColor(strokeColor.cgColor)
            ctx.setLineWidth(lineWidth)
            ctx.addPath(thumbPath.cgPath)
            ctx.strokePath()
        }
        if highlighted {
            ctx.setFillColor(UIColor(white: 0.0, alpha: 0.1).cgColor)
            ctx.addPath(thumbPath.cgPath)
            ctx.fillPath()
        }
    }
}

class DUPlayerPostionLayer: CALayer {
    var highlighted: Bool = false {
        didSet {
            setNeedsDisplay()
        }
    }
    override func draw(in ctx: CGContext) {
        let path = UIBezierPath(roundedRect: bounds, cornerRadius: 0)
        ctx.addPath(path.cgPath)
        ctx.setFillColor(UIColor.white.cgColor)
        ctx.addPath(path.cgPath)
        ctx.fillPath()
    }
}

@IBDesignable
public class DURangeSlider: UIControl {
    
    public var leftThumbImage : UIImage?{
        didSet {
            lowerThumbLayer.fillImage = leftThumbImage?.cgImage
            lowerThumbLayer.setNeedsDisplay()
        }
    }
    public var rightThumbImage : UIImage? {
        didSet {
            upperThumbLayer.fillImage = rightThumbImage?.cgImage
            upperThumbLayer.setNeedsDisplay()
        }
    }

    @IBInspectable public var minimumValue: Double = 0.0 {
        willSet(newValue) {
            assert(newValue < maximumValue, "RangeSlider: minimumValue should be lower than maximumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    @IBInspectable  public var trackBorderWidth : Double = 3.0 {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }

    @IBInspectable public var maximumValue: Double = 1.0 {
        willSet(newValue) {
            assert(newValue > minimumValue, "RangeSlider: maximumValue should be greater than minimumValue")
        }
        didSet {
            updateLayerFrames()
        }
    }
    
    @IBInspectable public var lowerValue: Double = 0.0 {
        didSet {
            if lowerValue < minimumValue {
                lowerValue = minimumValue
            }
            updateLayerFrames()
        }
    }
    
    @IBInspectable public var upperValue: Double = 1.0 {
        didSet {
            if upperValue > maximumValue {
                upperValue = maximumValue
            }
            updateLayerFrames()
        }
    }
    public var lowerValueRespectingThumbWidth: Double {
        get {
            return lowerValue + Double((thumbWidth/bounds.width))
        }
    }
    
    public var upperValueRespectingThumbWidth: Double {
        get {
            return upperValue
        }
    }
    
    public var thumbWidthRatio:Double {
        return  Double((self.thumbWidth/self.bounds.width))
    }
    
    var gapBetweenThumbs: Double {
        return 0.5 * Double(thumbWidth) * (maximumValue - minimumValue) / Double(bounds.width)
    }
    
    @IBInspectable public var trackTintColor: UIColor = UIColor(white: 0.9, alpha: 0.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var trackHighlightTintColor: UIColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var trackBorderTintColor: UIColor =  UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0) {
         didSet {
             trackLayer.setNeedsDisplay()
         }
     }
     
    
    @IBInspectable public var thumbTintColor: UIColor = UIColor.white {
        didSet {
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    
    @IBInspectable public var thumbBorderColor: UIColor = UIColor.gray {
        didSet {
            lowerThumbLayer.strokeColor = thumbBorderColor
            upperThumbLayer.strokeColor = thumbBorderColor
        }
    }
    
    @IBInspectable public var thumbBorderWidth: CGFloat = 0.5 {
        didSet {
            lowerThumbLayer.lineWidth = thumbBorderWidth
            upperThumbLayer.lineWidth = thumbBorderWidth
        }
    }
    
    @IBInspectable public var curvaceousness: CGFloat = 1.0 {
        didSet {
            if curvaceousness < 0.0 {
                curvaceousness = 0.0
            }
            
            if curvaceousness > 1.0 {
                curvaceousness = 1.0
            }
            
            trackLayer.setNeedsDisplay()
            lowerThumbLayer.setNeedsDisplay()
            upperThumbLayer.setNeedsDisplay()
        }
    }
    @IBInspectable public var playerPosition: Double = 1.0 {
        didSet{
            updateLayerFrames()
        }
    }
    fileprivate var previouslocation = CGPoint()
    
    fileprivate let trackLayer = DURangeSliderTrackLayer()
    fileprivate let lowerThumbLayer = TRRangeSliderThumbLayer()
    fileprivate let upperThumbLayer = TRRangeSliderThumbLayer()
    fileprivate let playerPostionLayer = DUPlayerPostionLayer()
    var thumbWidth: CGFloat! = 15
    var thumbHeight: CGFloat! = 15

    override public var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initializeLayers()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initializeLayers()
    }
    
    override public func layoutSublayers(of: CALayer) {
        super.layoutSublayers(of:layer)
        updateLayerFrames()
    }
  
    fileprivate func initializeLayers() {
        layer.backgroundColor = UIColor.clear.cgColor
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        lowerThumbLayer.rangeSlider = self
        lowerThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(lowerThumbLayer)
        
        upperThumbLayer.rangeSlider = self
        upperThumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(upperThumbLayer)
        
//        playerPostionLayer.contentsScale = UIScreen.main.scale
//        layer.addSublayer(playerPostionLayer)
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: 0)
        trackLayer.setNeedsDisplay()
        let playerPosX = CGFloat(positionForValue(Double(playerPosition))) - thumbWidth/2.0
       
        playerPostionLayer.frame = CGRect(x: playerPosX, y: -5, width: 2, height: bounds.height + 10)
        playerPostionLayer.setNeedsDisplay()
        
        let lowerThumbCenter = CGFloat(positionForValue(lowerValue))
        let yForThumbs = bounds.height/2 - thumbHeight/2
        lowerThumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth/2.0, y: yForThumbs, width: thumbWidth, height: thumbHeight)
        lowerThumbLayer.setNeedsDisplay()
        
        let upperThumbCenter = CGFloat(positionForValue(upperValue))
        upperThumbLayer.frame = CGRect(x: upperThumbCenter - thumbWidth/2.0, y: yForThumbs, width: thumbWidth, height: thumbHeight)
        upperThumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    func positionForValue(_ value: Double) -> Double {
         let val =  Double(bounds.width - thumbWidth) * (value - minimumValue) /
            (maximumValue - minimumValue) + Double(thumbWidth/2.0)
        if  value == minimumValue {
           return val - Double(thumbWidth/2.0)
        }
        else if value == maximumValue {
            return val + Double(thumbWidth/2.0)
        }
        return val
    }
    
    func boundValue(_ value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    
    // MARK: - Touches
    
    override public func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        previouslocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if lowerThumbLayer.frame.contains(previouslocation) {
            lowerThumbLayer.highlighted = true
        } else if upperThumbLayer.frame.contains(previouslocation) {
            upperThumbLayer.highlighted = true
        }
        else if playerPostionLayer.frame.contains(previouslocation) {
            playerPostionLayer.highlighted = true
        }
        return lowerThumbLayer.highlighted || upperThumbLayer.highlighted || playerPostionLayer.highlighted
    }
    
    override public func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        // Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previouslocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - bounds.height)
        
        previouslocation = location
        
        // Update the values
        if lowerThumbLayer.highlighted {
            lowerValue = boundValue(lowerValue + deltaValue, toLowerValue: minimumValue, upperValue: upperValue - gapBetweenThumbs)
        } else if upperThumbLayer.highlighted {
            upperValue = boundValue(upperValue + deltaValue, toLowerValue: lowerValue + gapBetweenThumbs, upperValue: maximumValue)
        }
        else if
            playerPostionLayer.highlighted {
            let rightValue = boundValue(Double(playerPosition + deltaValue), toLowerValue: minimumValue, upperValue: maximumValue)
            playerPosition = rightValue
        }
        
        sendActions(for: .valueChanged)
        
        return true
    }
    
    override public func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        lowerThumbLayer.highlighted = false
        upperThumbLayer.highlighted = false
    }
}
